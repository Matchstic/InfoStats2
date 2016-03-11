//
//  IS2WeatherProvider.m
//  InfoStats2
//
//  Created by Matt Clarke on 02/06/2015.
//

/*
 *
 *  Updating weather on iOS is a glorious pain in the arse. This daemon simplifies things 
 *  nicely enough for it all to work, and be readable too when doing so. Enjoy!
 *
 *  Due to changes in iOS 8 onwards, a daemon is necessary to be able to acheive location
 *  updating for local weather. This is because a new entitlement was introduced on
 *  locationd for privacy purposes; this daemon is signed with it, since we can't exactly 
 *  re-sign SpringBoard easily at runtime. Whilst this will always run in the background, 
 *  it has been found this has no discernible effect on battery life.
 *
 *  I don't recommend iterfacing with this daemon yourself; please use the provided public
 *  API, else you may release gremlins into your system.
 *
 *  Licensed under the BSD license.
 *
 */

#import "IS2WeatherProvider.h"
#import <Weather/TWCCityUpdater.h>
#import <objc/runtime.h>
#import <Weather/Weather.h>
#import <notify.h>

#define deviceVersion [[[UIDevice currentDevice] systemVersion] floatValue]

@interface WeatherPreferences (iOS7)
- (id)loadSavedCityAtIndex:(int)arg1;
@end

@interface WeatherLocationManager (iOS8)
- (bool)localWeatherAuthorized;
- (void)_setAuthorizationStatus:(int)arg1;
- (void)setAuthorizationStatus:(int)arg1;
- (void)setLocationTrackingReady:(bool)arg1 activelyTracking:(bool)arg2; // not in 8.3
@end

@interface WeatherLocationManager (iOS8_3)
- (void)setLocationTrackingReady:(bool)arg1 activelyTracking:(bool)arg2 watchKitExtension:(BOOL)arg3;
@end

@interface City (iOS7)
@property (assign, nonatomic) BOOL isRequestedByFrameworkClient;
@end

@interface City (IOS9)
- (void)addUpdateObserver:(id)arg1;
- (int)lastUpdateStatus;
- (id)state;
@end

@interface TWCLocationUpdater : TWCUpdater
+(id)sharedLocationUpdater;
-(void)updateWeatherForLocation:(id)arg1 city:(id)arg2 withCompletionHandler:(id)arg3;
@end

@interface CLLocationManager (Private)
+(void)setAuthorizationStatus:(bool)arg1 forBundleIdentifier:(id)arg2;
-(id)initWithEffectiveBundleIdentifier:(id)arg1;
-(void)requestAlwaysAuthorization;
-(void)setPausesLocationUpdatesAutomatically:(bool)arg1;
-(void)setPersistentMonitoringEnabled:(bool)arg1;
-(void)setPrivateMode:(bool)arg1;
@end

@interface CPDistributedMessagingCenter : NSObject
+(CPDistributedMessagingCenter*)centerNamed:(NSString*)serverName;
-(BOOL)sendMessageName:(NSString*)name userInfo:(NSDictionary*)info;
@end

void rocketbootstrap_distributedmessagingcenter_apply(CPDistributedMessagingCenter *messaging_center);

static City *currentCity;
static int notifyToken;

@implementation IS2WeatherUpdater

-(id)initWithLocationManager:(IS2LocationManager*)locationManager {
    [City initialize];
    
    self = [super init];
    if (self) {
        self.locationManager = locationManager;
        [self.locationManager registerNewCallbackForLocationData:^(CLLocation* mostRecentLocation) {
            if (mostRecentLocation) {
                [self updateLocalCityWithLocation:mostRecentLocation];
            } else {
                NSLog(@"[InfoStats2d | Weather] :: Cannot determine location; using extrapolated data from last update.");
                notify_post("com.matchstic.infostats2/weatherUpdateCompleted");
            }
        }];
        
        self.reach = [Reachability reachabilityForInternetConnection];
    }
    
    return self;
}

-(void)updateWeather {
    if (self.reach.isReachable) {
        [self fullUpdate];
        return;
    } else {
        // No data connection; allow for extrapolated data to be used instead from
        // the current City instance.
        NSLog(@"[InfoStats2 | Weather]d :: No data connection; using extrapolated data from last update.");
        notify_post("com.matchstic.infostats2/weatherUpdateCompleted");
        return;
    }
}

#pragma mark Backend

-(void)fullUpdate {
    if (deviceVersion >= 8.0) {
        if ([[WeatherLocationManager sharedWeatherLocationManager] respondsToSelector:@selector(setLocationTrackingReady:activelyTracking:)]) {
            [[WeatherLocationManager sharedWeatherLocationManager] setLocationTrackingReady:([self.locationManager currentAuthorisationStatus] != kCLAuthorizationStatusAuthorized ? NO : YES) activelyTracking:NO];
        } else {
            [(WeatherLocationManager*)[WeatherLocationManager sharedWeatherLocationManager] setDelegate:self.locationManager];
            [[WeatherLocationManager sharedWeatherLocationManager] setLocationTrackingReady:([self.locationManager currentAuthorisationStatus] != kCLAuthorizationStatusAuthorized ? NO : YES) activelyTracking:NO watchKitExtension:NO];
        }
        
        if ([[WeatherLocationManager sharedWeatherLocationManager] respondsToSelector:@selector(_setAuthorizationStatus:)])
             [[WeatherLocationManager sharedWeatherLocationManager] _setAuthorizationStatus:[self.locationManager currentAuthorisationStatus]];
        else if ([[WeatherLocationManager sharedWeatherLocationManager] respondsToSelector:@selector(setAuthorizationStatus:)])
            [[WeatherLocationManager sharedWeatherLocationManager] setAuthorizationStatus:[self.locationManager currentAuthorisationStatus]];
    }
    
    if ([self.locationManager currentAuthorisationStatus] == kCLAuthorizationStatusAuthorized) {
        NSLog(@"[InfoStats2 | Weather]d :: Updating, and also getting a new location");
        
        currentCity = [[WeatherPreferences sharedPreferences] localWeatherCity];
        if ([currentCity respondsToSelector:@selector(associateWithDelegate:)])
            [currentCity associateWithDelegate:self];
        else if ([currentCity respondsToSelector:@selector(addUpdateObserver:)])
            [currentCity addUpdateObserver:self]; // Essential for getting callbacks when the city is updated.
        
        [[WeatherPreferences sharedPreferences] setLocalWeatherEnabled:YES];
        
        // Force finding of new location, and then update from there.
        [self.locationManager.locationManager startUpdatingLocation];
    } else if ([self.locationManager currentAuthorisationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"[InfoStats2d | Weather] :: Updating first city in Weather.app");
        
        if (![[WeatherPreferences sharedPreferences] respondsToSelector:@selector(loadSavedCityAtIndex:)]) {
            // This is untested; I have no idea if this will work, but I hope so.
            @try {
                currentCity = [[[WeatherPreferences sharedPreferences] loadSavedCities] firstObject];
            } @catch (NSException *e) {
                NSLog(@"[InfoStats2d | Weather] :: Failed to load first city in Weather.app for reason:\n%@", e);
            }
        } else
            currentCity = [[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0];
        
        if ([currentCity isLocalWeatherCity]) {
            // Oh for crying out loud, still have old local city in place!
            if (![[WeatherPreferences sharedPreferences] respondsToSelector:@selector(loadSavedCityAtIndex:)]) {
                // This is untested; I have no idea if this will work, but I hope so.
                @try {
                    currentCity = [[WeatherPreferences sharedPreferences] loadSavedCities][1];
                } @catch (NSException *e) {
                    NSLog(@"[InfoStats2d | Weather] :: Failed to load first city in Weather.app for reason:\n%@", e);
                }
            } else
                currentCity = [[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:1];
        }
        
        if ([currentCity respondsToSelector:@selector(associateWithDelegate:)])
            [currentCity associateWithDelegate:self];
        else if ([currentCity respondsToSelector:@selector(addUpdateObserver:)])
            [currentCity addUpdateObserver:self];
        
        [[WeatherPreferences sharedPreferences] setLocalWeatherEnabled:NO];
        
        [self updateCurrentCityWithoutLocation];
    }
}

-(void)updateLocalCityWithLocation:(CLLocation*)location {
    if (deviceVersion >= 8.0) {
        [[objc_getClass("TWCLocationUpdater") sharedLocationUpdater] updateWeatherForLocation:location city:currentCity];
    } else {
        [[objc_getClass("LocationUpdater") sharedLocationUpdater] updateWeatherForLocation:location city:currentCity];
    }
}

-(void)updateCurrentCityWithoutLocation {
    if (deviceVersion >= 8.0)
        [[objc_getClass("TWCCityUpdater") sharedCityUpdater] updateWeatherForCity:currentCity];
    else
        [[objc_getClass("WeatherIdentifierUpdater") sharedWeatherIdentifierUpdater] updateWeatherForCity:currentCity];
}

#pragma mark Delegates

-(void)cityDidStartWeatherUpdate:(id)city {
    // Nothing to do here currently.
}

-(void)cityDidFinishWeatherUpdate:(City*)city {
    currentCity = city;
    
    /* 
     *  We should save this data so it can be loaded into the SpringBoard portion.
     *
     *  WeatherPreferences seems to be a pain when saving cities, and requires isCelsius to
     *  be re-set again. No idea why, but hey, goddammit Apple.
     *
     *  I bet the saving issues seen are casued by this method; the one where the false data is set to the first city
     */
    
    /*BOOL isCelsius = [[WeatherPreferences sharedPreferences] isCelsius];
    
    if ([currentCity isLocalWeatherCity]) {
        [[WeatherPreferences sharedPreferences] saveToDiskWithLocalWeatherCity:city];
    } else {
        NSMutableArray *cities = [[[WeatherPreferences sharedPreferences] loadSavedCities] mutableCopy];
        [cities removeObjectAtIndex:0];
        [cities insertObject:city atIndex:0];
        
        [[WeatherPreferences sharedPreferences] saveToDiskWithCities:cities activeCity:0];
    }
    
    [[WeatherPreferences sharedPreferences] setCelsius:isCelsius];
    
    [[WeatherPreferences sharedPreferences] synchronizeStateToDisk];
    [[WeatherPreferences sharedPreferences] saveToUbiquitousStore];*/
    
    NSLog(@"[InfoStats2d | Weather] :: Updated, returning data.");
    
    // we have updated weather, but, shouldn't we just send this back to SB via a dict?
    NSDictionary *updated = [[WeatherPreferences sharedPreferences] preferencesDictionaryForCity:currentCity];
    
    CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:@"com.matchstic.infostats2.weather"];
    rocketbootstrap_distributedmessagingcenter_apply(c);
    [c sendMessageName:@"weatherData" userInfo:updated]; //send an NSDictionary here to pass data
    
    // Return a message back to SpringBoard that updating is now done.
    notify_post("com.matchstic.infostats2/weatherUpdateCompleted");
}

@end
