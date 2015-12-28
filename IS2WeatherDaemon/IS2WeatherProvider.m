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

static City *currentCity;
static int notifyToken;
static int authorisationStatus;

@implementation IS2WeatherUpdater

-(id)init {
    [City initialize];
    
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
        [self.locationManager setDelegate:self];
        [self.locationManager setActivityType:CLActivityTypeOtherNavigation]; // Allows use of GPS
        
        self.reach = [Reachability reachabilityForInternetConnection];

        authorisationStatus = kCLAuthorizationStatusNotDetermined;
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
        NSLog(@"*** [InfoStats2 | Weather] :: No data connection; using extrapolated data from last update.");
        notify_post("com.matchstic.infostats2/weatherUpdateCompleted");
        return;
    }
}

#pragma mark Backend

-(void)fullUpdate {
    if (deviceVersion >= 8.0) {
        if ([[WeatherLocationManager sharedWeatherLocationManager] respondsToSelector:@selector(setLocationTrackingReady:activelyTracking:)]) {
            [[WeatherLocationManager sharedWeatherLocationManager] setLocationTrackingReady:(authorisationStatus != kCLAuthorizationStatusAuthorized ? NO : YES) activelyTracking:NO];
        } else {
            [[WeatherLocationManager sharedWeatherLocationManager] setDelegate:self];
            [[WeatherLocationManager sharedWeatherLocationManager] setLocationTrackingReady:(authorisationStatus != kCLAuthorizationStatusAuthorized ? NO : YES) activelyTracking:NO watchKitExtension:NO];
        }
        
        if ([[WeatherLocationManager sharedWeatherLocationManager] respondsToSelector:@selector(_setAuthorizationStatus:)])
             [[WeatherLocationManager sharedWeatherLocationManager] _setAuthorizationStatus:authorisationStatus];
        else if ([[WeatherLocationManager sharedWeatherLocationManager] respondsToSelector:@selector(setAuthorizationStatus:)])
            [[WeatherLocationManager sharedWeatherLocationManager] setAuthorizationStatus:authorisationStatus];
    }
    
    if (authorisationStatus == kCLAuthorizationStatusAuthorized) {
        NSLog(@"*** [InfoStats2 | Weather] :: Updating, and also getting a new location");
        
        currentCity = [[WeatherPreferences sharedPreferences] localWeatherCity];
        if ([currentCity respondsToSelector:@selector(associateWithDelegate:)])
            [currentCity associateWithDelegate:self];
        else if ([currentCity respondsToSelector:@selector(addUpdateObserver:)])
            [currentCity addUpdateObserver:self]; // Essential for getting callbacks when the city is updated.
        
        [[WeatherPreferences sharedPreferences] setLocalWeatherEnabled:YES];
        
        // Force finding of new location, and then update from there.
        [self.locationManager startUpdatingLocation];
    } else if (authorisationStatus == kCLAuthorizationStatusDenied) {
        NSLog(@"*** [InfoStats2 | Weather] :: Updating first city in Weather.app");
        
        if (deviceVersion < 6.0) {
            // This is untested; I have no idea if this will work, but I hope so.
            @try {
                currentCity = [[[WeatherPreferences sharedPreferences] loadSavedCities] firstObject];
            } @catch (NSException *e) {
                NSLog(@"*** [InfoStats2 | Weather] :: Failed to load first city in Weather.app for reason:\n%@", e);
            }
        }
        currentCity = [[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0];
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
    
    BOOL isCelsius = [[WeatherPreferences sharedPreferences] isCelsius];
    
    if ([currentCity isLocalWeatherCity]) {
        [[WeatherPreferences sharedPreferences] saveToDiskWithLocalWeatherCity:city];
    } else {
        NSMutableArray *cities = [[[WeatherPreferences sharedPreferences] loadSavedCities] mutableCopy];
        [cities removeObjectAtIndex:0];
        [cities insertObject:city atIndex:0];
        
        [[WeatherPreferences sharedPreferences] saveToDiskWithCities:cities activeCity:0];
    }
    
    [[WeatherPreferences sharedPreferences] setCelsius:isCelsius];
    
    NSLog(@"*** [InfoStats2 | Weather] :: Updated, returning data.");
    
    // Return a message back to SpringBoard that updating is now done.
    notify_post("com.matchstic.infostats2/weatherUpdateCompleted");
}

- (void)locationManager:(id)arg1 didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"*** [InfoStats2 | Weather] :: Location manager auth state changed to %d.", status);
    
    int oldStatus = authorisationStatus;
    authorisationStatus = status;
    
    if (oldStatus == kCLAuthorizationStatusAuthorized && oldStatus != status) {
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"*** [InfoStats2 | Weather] :: Location manager did update locations.");
    
    // Locations updated! We can now ask for an update to weather with the new locations.
    CLLocation *mostRecentLocation = [[locations lastObject] copy];
    if (mostRecentLocation) {
        [self updateLocalCityWithLocation:mostRecentLocation];
    } else {
        NSLog(@"*** [InfoStats2 | Weather] :: Cannot determine location; using extrapolated data from last update.");
        notify_post("com.matchstic.infostats2/weatherUpdateCompleted");
    }
        
    [self.locationManager stopUpdatingLocation];
}

#pragma mark Message listening from SpringBoard

- (void)timerFireMethod:(NSTimer *)timer {
	int status, check;
	static char first = 0;
	if (!first) {
		status = notify_register_check("com.matchstic.infostats2/requestWeatherUpdate", &notifyToken);
		if (status != NOTIFY_STATUS_OK) {
			fprintf(stderr, "registration failed (%u)\n", status);
			return;
		}
        
		first = 1;
        
        return; // We don't want to update the weather on the first run, only when requested.
	}
    
	status = notify_check(notifyToken, &check);
	if (status == NOTIFY_STATUS_OK && check != 0) {
		NSLog(@"*** [InfoStats2 | Weather] :: Weather update request received.");
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self updateWeather];
        });
	}
}

@end
