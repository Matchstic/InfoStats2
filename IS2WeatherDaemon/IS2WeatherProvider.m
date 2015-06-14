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

/*@interface WeatherLocationManager (iOS7)
@property(retain) CLLocationManager * locationManager;
- (CLLocation*)location;
- (void)setLocationTrackingReady:(bool)arg1 activelyTracking:(bool)arg2;
@end

@interface WeatherLocationManager (iOS8)
- (bool)localWeatherAuthorized;
- (void)_setAuthorizationStatus:(int)arg1;
@end*/

@interface City (iOS7)
@property (assign, nonatomic) BOOL isRequestedByFrameworkClient;
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
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [self.locationManager setDistanceFilter:1000.0];
        [self.locationManager setDelegate:self];
        [self.locationManager setActivityType:CLActivityTypeOther];
        
        if ([self.locationManager respondsToSelector:@selector(setPersistentMonitoringEnabled:)]) {
            [self.locationManager setPersistentMonitoringEnabled:NO];
        }
        
        if ([self.locationManager respondsToSelector:@selector(setPrivateMode:)]) {
            [self.locationManager setPrivateMode:YES];
        }

    }
    
    return self;
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
    //BOOL localWeather = [CLLocationManager locationServicesEnabled];
    
    if (authorisationStatus == kCLAuthorizationStatusAuthorized) {
        /*if (!self.setup) {
            [self setupLocationWeatherStuff];
        }*/
        
        currentCity = [[WeatherPreferences sharedPreferences] localWeatherCity];
        [currentCity associateWithDelegate:self];
        
        // Force finding of new location, and then update from there.
        [self.locationManager startUpdatingLocation];
    } else {
        currentCity = [[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0];
        [currentCity associateWithDelegate:self];
        
        //self.setup = YES;
        
        [self updateCurrentCityWithoutLocation];
    }
}

/*-(void)setupLocationWeatherStuff {
    currentCity = [[WeatherPreferences sharedPreferences] localWeatherCity];
    [currentCity associateWithDelegate:self];
    
    //[[WeatherLocationManager sharedWeatherLocationManager] setDelegate:self];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        //[[WeatherLocationManager sharedWeatherLocationManager] setLocationTrackingReady:NO activelyTracking:NO];
        //[[WeatherLocationManager sharedWeatherLocationManager] _setAuthorizationStatus:3];
    }
    
    //[[WeatherPreferences sharedPreferences] setLocalWeatherEnabled:YES];
    
    self.setup = YES;
}*/

/*-(void)unloadLocationStuff {
    currentCity = [[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0];
    [currentCity associateWithDelegate:self];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        //[[WeatherLocationManager sharedWeatherLocationManager] setLocationTrackingReady:NO activelyTracking:NO];
        //[[WeatherLocationManager sharedWeatherLocationManager] _setAuthorizationStatus:2];
    }
    
    //[[WeatherPreferences sharedPreferences] setLocalWeatherEnabled:NO];
}*/

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
    // Nothing to do here currently.
}

-(void)cityDidFinishWeatherUpdate:(id)city {
    currentCity = city;
    
    // Return a message back to SpringBoard that updating is now done.
    notify_post("com.matchstic.infostats2/weatherUpdateCompleted");
}

- (void)locationManager:(id)arg1 didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"*** [InfoStats2 | Weather] :: Location manager auth state changed to: %d.", status);
    
    /*if (status == kCLAuthorizationStatusAuthorized) {
        [self setupLocationWeatherStuff];
    } else {
        [self unloadLocationStuff];
    }*/
    
    authorisationStatus = status;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"*** [InfoStats2 | Weather] :: Location manager did update locations.");
    
    // Locations updated! We can now ask for an update to weather with the new locations.
    CLLocation *mostRecentLocation = [[locations lastObject] copy];
    [self updateLocalCityWithLocation:mostRecentLocation];
    
    [self.locationManager stopUpdatingLocation];
}

#pragma mark Message listening from SpringBoard

- (void)timerFireMethod:(NSTimer *)timer {
	[timer invalidate];
    
	int status, check;
	static char first = 0;
	if (!first) {
		status = notify_register_check("com.matchstic.infostats2/requestWeatherUpdate", &notifyToken);
		if (status != NOTIFY_STATUS_OK) {
			fprintf(stderr, "registration failed (%u)\n", status);
			return;
		}
        
		first = 1;
	}
    
	status = notify_check(notifyToken, &check);
	if (status == NOTIFY_STATUS_OK && check != 0) {
		NSLog(@"*** [InfoStats2 | Weather] :: Weather update request received.");
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self updateWeather];
        });
	}
    
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
