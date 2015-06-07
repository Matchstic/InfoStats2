//
//  IS2WeatherProvider.m
//  InfoStats2
//
//  Created by Matt Clarke on 02/06/2015.
//
//

#import "IS2WeatherProvider.h"
#import <Weather/TWCCityUpdater.h>
#import <objc/runtime.h>
#import <Weather/Weather.h>
#import "Reachability.h"
#import <notify.h>

@interface WeatherPreferences (iOS7)
- (id)loadSavedCityAtIndex:(int)arg1;
@end

@interface CLLocationManager (iOS8)
+ (void)setAuthorizationStatus:(bool)arg1 forBundleIdentifier:(id)arg2;
- (id)initWithEffectiveBundleIdentifier:(id)arg1;
-(void)requestAlwaysAuthorization;
@end

@interface WeatherLocationManager (iOS7)
@property(retain) CLLocationManager * locationManager;
- (CLLocation*)location;
- (void)setLocationTrackingReady:(bool)arg1 activelyTracking:(bool)arg2;
@end

@interface WeatherLocationManager (iOS8)
- (bool)localWeatherAuthorized;
- (void)_setAuthorizationStatus:(int)arg1;
@end

@interface City (iOS7)
@property (assign, nonatomic) unsigned conditionCode;
@property (assign, nonatomic) BOOL isRequestedByFrameworkClient;

+(id)descriptionForWeatherUpdateDetail:(unsigned)arg1;
@end

@interface TWCLocationUpdater : TWCUpdater
+ (id)sharedLocationUpdater;
- (void)updateWeatherForLocation:(id)arg1 city:(id)arg2 withCompletionHandler:(id)arg3;
@end

@interface IS2WeatherUpdater ()
-(void)setupLocationWeatherStuff;
@end

static City *currentCity;
static IS2WeatherUpdater *updater;
int notifyToken;

@implementation IS2WeatherUpdater

+(instancetype)sharedInstance {
    if (!updater) {
        [City initialize];
        updater = [[IS2WeatherUpdater alloc] init];
        
        [[WeatherLocationManager sharedWeatherLocationManager] setLocationManager:[[CLLocationManager alloc] init]];
        [[[WeatherLocationManager sharedWeatherLocationManager] locationManager] setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [[[WeatherLocationManager sharedWeatherLocationManager] locationManager] setDistanceFilter:500.0];
        [[[WeatherLocationManager sharedWeatherLocationManager] locationManager] setDelegate:updater];
        
        // Register for update notification.
        notify_register_dispatch("com.matchstic.infostats2/requestWeatherUpdate", &notifyToken, dispatch_get_main_queue(), ^(int t) {
            NSLog(@"*** [InfoStats2 | Weather] :: Weather update request received.");
            
            [updater updateWeather];
        });
    }
    
    return updater;
}

-(void)updateWeather {
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    if (reach.isReachable) {
        [self fullUpdate];
        return;
    }
    
    reach.reachableBlock = ^(Reachability *reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (reach.isReachable) {
                [self fullUpdate];
                [reach stopNotifier];
            }
        });
    };
    
    [reach startNotifier];
}

// Backend

-(void)fullUpdate {
    BOOL localWeather = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        localWeather = [[WeatherLocationManager sharedWeatherLocationManager] localWeatherAuthorized];
    else
        localWeather = [CLLocationManager locationServicesEnabled];
    
    if (localWeather) {
        if (!self.setup) {
            [self setupLocationWeatherStuff];
        }
        
        // Force finding of new location, and then update from there.
        [[(WeatherLocationManager*)[WeatherLocationManager sharedWeatherLocationManager] locationManager] startUpdatingLocation];
    } else {
        currentCity = [[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0];
        [currentCity associateWithDelegate:self];
        
        self.setup = YES;
        
        [self updateCurrentCityWithoutLocation];
    }
}

-(void)setupLocationWeatherStuff {
    currentCity = [[WeatherPreferences sharedPreferences] localWeatherCity];
    [currentCity associateWithDelegate:self];
    
    [[WeatherLocationManager sharedWeatherLocationManager] setDelegate:self];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[WeatherLocationManager sharedWeatherLocationManager] setLocationTrackingReady:YES activelyTracking:NO];
        [[WeatherLocationManager sharedWeatherLocationManager] _setAuthorizationStatus:3];
    }
    
    [[WeatherPreferences sharedPreferences] setLocalWeatherEnabled:YES];
    
    self.setup = YES;
}

-(void)unloadLocationStuff {
    currentCity = [[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0];
    [currentCity associateWithDelegate:self];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[WeatherLocationManager sharedWeatherLocationManager] setLocationTrackingReady:YES activelyTracking:NO];
        [[WeatherLocationManager sharedWeatherLocationManager] _setAuthorizationStatus:2];
    }
    
    [[WeatherPreferences sharedPreferences] setLocalWeatherEnabled:NO];
}

-(void)updateLocalCityWithLocation:(CLLocation*)location {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[objc_getClass("TWCLocationUpdater") sharedLocationUpdater] updateWeatherForLocation:location city:currentCity];
    } else {
        [[LocationUpdater sharedLocationUpdater] updateWeatherForLocation:location city:currentCity];
    }
}

-(void)updateCurrentCityWithoutLocation {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [[objc_getClass("TWCCityUpdater") sharedCityUpdater] updateWeatherForCity:currentCity];
    else
        [[WeatherIdentifierUpdater sharedWeatherIdentifierUpdater] updateWeatherForCity:currentCity];
}

#pragma mark Delegates

-(void)cityDidStartWeatherUpdate:(id)city {
    
}

-(void)cityDidFinishWeatherUpdate:(id)city {
    currentCity = city;
    
    // Return a message back to SpringBoard that updating is now done.
    notify_post("com.matchstic.infostats2/weatherUpdateCompleted");
}

- (void)locationManager:(id)arg1 didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"*** [InfoStats2 | Weather] :: Location manager auth state changed to: %d", status);
    
    if (status == kCLAuthorizationStatusAuthorized) {
        [self setupLocationWeatherStuff];
    } else {
        [self unloadLocationStuff];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"*** [InfoStats2 | Weather] :: Location manager did update locations.");
    
    // Locations updated! We can now ask for an update to weather with the new locations.
    CLLocation *mostRecentLocation = [locations lastObject];
    [self updateLocalCityWithLocation:mostRecentLocation];
    
    [[(WeatherLocationManager*)[WeatherLocationManager sharedWeatherLocationManager] locationManager] stopUpdatingLocation];
}

- (void)timerFireMethod:(NSTimer *)timer {
	[timer invalidate];
    
	//start a timer so that the process does not exit.
	timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                     interval:5
                                       target:self
                                     selector:@selector(timerFireMethod:)
                                     userInfo:nil
                                      repeats:YES];
    
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

@end
