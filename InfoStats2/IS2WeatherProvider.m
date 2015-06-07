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

static City *currentCity;
static IS2WeatherProvider *provider;

int notifyToken;
int status;

@implementation IS2WeatherProvider

+(instancetype)sharedInstance {
    if (!provider) {
        [City initialize];
        provider = [[IS2WeatherProvider alloc] init];
        
        status = notify_register_dispatch("com.matchstic.infostats2/weatherUpdateCompleted", &notifyToken, dispatch_get_main_queue(), ^(int t) {
            NSLog(@"*** [InfoStats2] :: Weather has been updated, reloading data.");
            
            BOOL localWeather = NO;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
                localWeather = [[WeatherLocationManager sharedWeatherLocationManager] localWeatherAuthorized];
            else
                localWeather = [CLLocationManager locationServicesEnabled];
            
            if (localWeather) {
                // local city updated
                currentCity = [[WeatherPreferences sharedPreferences] localWeatherCity];
            } else {
                // First city updated
                currentCity = [[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0];
            }
            
            // Run callback block!
            [provider.callbackBlock invoke];
            
            provider.isUpdating = NO;
        });

    }
    
    return provider;
}

-(void)updateWeatherWithCallback:(void (^)(void))callbackBlock {
    self.isUpdating = YES;
    self.callbackBlock = callbackBlock;
    
    NSLog(@"*** [InfoStats2] :: Attempting to request weather update.");
    
    // Communicate via notify() with daemon for weather updates.
    notify_post("com.matchstic.infostats2/requestWeatherUpdate");
}

-(int)currentTemperature {
    return [currentCity.temperature intValue];
}

-(NSString*)currentLocation {
    return currentCity.name;
}

@end
