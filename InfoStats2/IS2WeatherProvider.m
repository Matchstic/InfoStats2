//
//  IS2WeatherProvider.m
//  InfoStats2
//
//  Created by Matt Clarke on 02/06/2015.
//
//

#import "IS2WeatherProvider.h"
#import <objc/runtime.h>
#import <Weather/Weather.h>
#import <notify.h>
#import "IS2Extensions.h"
#include <dlfcn.h>
#import <substrate.h>

//extern float ChanceOfRainWithHourlyForecasts(NSArray *forecasts);

#define deviceVersion [[[UIDevice currentDevice] systemVersion] floatValue]

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

@interface HourlyForecast (Additions)
@property (nonatomic) unsigned int eventType;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *detail;
@end

@interface City (iOS7)
@property (assign, nonatomic) unsigned conditionCode;
@property (assign, nonatomic) BOOL isRequestedByFrameworkClient;
- (id)naturalLanguageDescription;
- (int)precipitationForecast;
+(id)descriptionForWeatherUpdateDetail:(unsigned)arg1;
@property(assign, nonatomic) id feelsLike;	// G=0x1f61; S=0x1f71; @synthesize=_feelsLike
@end

@interface CPDistributedMessagingCenter : NSObject
+(CPDistributedMessagingCenter*)centerNamed:(NSString*)serverName;
-(BOOL)sendMessageName:(NSString*)name userInfo:(NSDictionary*)info;
-(void)runServerOnCurrentThread;
-(void)stopServer;
-(void)registerForMessageName:(NSString*)messageName target:(id)target selector:(SEL)selector;
@end

@interface WFTemperature : NSObject
@property (nonatomic) double celsius;
@property (nonatomic) double fahrenheit;
@property (nonatomic) double kelvin;
@end

@interface IS2System : NSObject
+(BOOL)isDeviceIn24Time;
+(NSString*)translatedAMString;
+(NSString*)translatedPMString;
@end

void rocketbootstrap_distributedmessagingcenter_apply(CPDistributedMessagingCenter *messaging_center);

NSString *WeatherWindSpeedUnitForCurrentLocale();

//static City *currentCity;
static City *currentCity;
static CPDistributedMessagingCenter *center;
static IS2WeatherProvider *provider;
static void (^block)();

int notifyToken;
int status;
int firstUpdate = 0;

@implementation IS2WeatherProvider

+(instancetype)sharedInstance {
    if (!provider) {
        [City initialize];
        provider = [[IS2WeatherProvider alloc] init];
        provider.weatherFrameworkBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Weather.framework"];
    }
    
    return provider;
}

-(void)setupForTweakLoaded {
    [self setCurrentCity];
    
    center = [CPDistributedMessagingCenter centerNamed:@"com.matchstic.infostats2.weather"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/librocketbootstrap.dylib"])
        rocketbootstrap_distributedmessagingcenter_apply(center);
    
    [center runServerOnCurrentThread];
    [center registerForMessageName:@"weatherData" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
    
    lastUpdateTime = time(NULL);
}

-(id)city {
    return currentCity;
}

// PLEASE do not ever call this directly; it's not exposed publicly in the API for a reason.
-(void)updateWeatherWithCallback:(void (^)(void))callbackBlock {
    self.isUpdating = YES;
    block = nil;
    block = callbackBlock;
    
    NSLog(@"[InfoStats2 | Weather] :: Attempting to request weather update.");
    
    // Communicate via notify() with daemon for weather updates.
    notify_post("com.matchstic.infostats2/requestWeatherUpdate");
    
    _updateTimoutTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(weatherUpdateTimeoutHandler:) userInfo:nil repeats:NO];
}

-(NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo {
    // Process userinfo (simple dictionary) and return a dictionary (or nil)
    if (![name isEqualToString:@"weatherData"]) return nil;
    
    NSLog(@"[InfoStats2 | Weather] :: Weather has been updated, reloading data.");
    
    // UserInfo will be the City in dict form!
    currentCity = [[WeatherPreferences sharedPreferences] cityFromPreferencesDictionary:userinfo];
    // Run callback block, but only if we actually have valid data.
    if (currentCity && block) {
        block();
    }
    
    self.isUpdating = NO;
    
    return nil;
}

-(void)weatherUpdateTimeoutHandler:(id)sender {
    NSLog(@"[InfoStats2 | Weather] :: Update timed out.");
    self.isUpdating = NO;
    
    [_updateTimoutTimer invalidate];
    _updateTimoutTimer = nil;
}

-(void)setCurrentCity {
    BOOL localWeather = [CLLocationManager locationServicesEnabled];
    
    if (localWeather) {
        // Local city updated
        currentCity = [[WeatherPreferences sharedPreferences] localWeatherCity];
    } else {
        // First city updated
        if (![[WeatherPreferences sharedPreferences] respondsToSelector:@selector(loadSavedCityAtIndex:)]) {
            // This is untested; I have no idea if this will work, but I hope so.
            @try {
                currentCity = [[[WeatherPreferences sharedPreferences] loadSavedCities] firstObject];
            } @catch (NSException *e) {
                NSLog(@"[InfoStats2 | Weather] :: Failed to load first city in Weather.app for reason:\n%@", e);
            }
        } else
            currentCity = [[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0];
    }
}

#pragma mark Translations

// Thanks to Andrew Wiik for this function.
// TODO: Need to verify it back to iOS 6.
-(NSString*)nameForCondition:(int)condition {
    // Get image for the weather framework to speed up searching.
    MSImageRef weather = MSGetImageByName("/System/Library/PrivateFrameworks/Weather.framework/Weather");
    
    CFStringRef *_weatherDescription = (CFStringRef*)MSFindSymbol(weather, "_WeatherDescription") + condition;
    NSString *cond = (__bridge id)*_weatherDescription;
    
    return [self.weatherFrameworkBundle localizedStringForKey:cond value:@"" table:@"WeatherFrameworkLocalizableStrings"];
}

-(NSString*)translatedWindSpeedUnits {
    return [self.weatherFrameworkBundle localizedStringForKey:WeatherWindSpeedUnitForCurrentLocale() value:@"" table:@"WeatherFrameworkLocalizableStrings"];
}

#pragma mark Data access

-(int)currentTemperature {
    // On iOS 10 and higher, the temperature is of class WFTemperature.
    if ([currentCity.temperature isKindOfClass:objc_getClass("WFTemperature")]) {
        WFTemperature *temp = (WFTemperature*)currentCity.temperature;
        return [[WeatherPreferences sharedPreferences] isCelsius] ? (int)temp.celsius : (int)temp.fahrenheit;
    } else {
        int temp = [currentCity.temperature intValue];
    
        // Need to convert to Farenheit ourselves annoyingly
        if (![[WeatherPreferences sharedPreferences] isCelsius])
            temp = ((temp*9)/5) + 32;
    
        return temp;
    }
}

-(NSString*)currentLocation {
    return currentCity.name;
}

-(int)currentCondition {
    int cond = 0;
    
    if (deviceVersion >= 7.0)
        cond =  currentCity.conditionCode;
    else
        cond = currentCity.bigIcon;
    
    if (cond == 32 && ![self isDay]) {
        cond = 31;
    }
    
    if (cond < 0) {
        cond = 0;
    }
    
    return cond;
}

-(NSString*)currentConditionAsString {
    return [self nameForCondition:[self currentCondition]];
}

-(NSString*)naturalLanguageDescription {
    NSString *output = @"";
    
    if ([currentCity respondsToSelector:@selector(naturalLanguageDescription)]) {
        output = [currentCity naturalLanguageDescription];
    } else {
        output = [self currentConditionAsString];
    }
    
    return output;
}

-(int)highForCurrentDay {
    return [self calculateAverageTempIsHigh:YES];
}

-(int)lowForCurrentDay {
    return [self calculateAverageTempIsHigh:NO];
}

-(int)calculateAverageTempIsHigh:(BOOL)isHigh {
    DayForecast *forecast = [[currentCity dayForecasts] firstObject];
    int temp = [(isHigh ? forecast.high : forecast.low) intValue];
    
    // Need to convert to Farenheit ourselves annoyingly
    if (![[WeatherPreferences sharedPreferences] isCelsius])
        temp = ((temp*9)/5) + 32;
    
    return temp;
}

-(int)currentWindSpeed {
    // Convert between mph and kph. Data comes in as kph
    if ([self isWindSpeedMph]) {
        float val = (float)currentCity.windSpeed / 1.609344;
        
        // Round val to nearest whole number.
        val = roundf(val);
        
        return val;
    }
    
    return currentCity.windSpeed;
}

-(BOOL)isCelsius {
    return [[WeatherPreferences sharedPreferences] isCelsius];
}

-(BOOL)isWindSpeedMph {
    // *sigh* There is no easy way to determine when a locale uses metric, but also mph for speeds.
    // This is mainly Ol' Blighty being a pain in the arse.
    
    if ([[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"GB"])
        return YES;
    
    NSNumber *val = [[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem];
    return ![val boolValue];
}

-(int)currentDewPoint {
    int temp = (int)currentCity.dewPoint;
    
    if (![[WeatherPreferences sharedPreferences] isCelsius])
        temp = ((temp*9)/5) + 32;
    
    return temp;
}

-(int)currentHumidity {
    return (int)currentCity.humidity;
}

-(int)currentWindChill {
    return (int)currentCity.windChill;
}

-(int)currentVisibilityPercent {
    return (int)currentCity.visibility;
}

// Available for iOS 7+
-(int)currentChanceOfRain {
    return 0.0;
    
    /*CGFloat output = 0.0;
    
    void *weather = dlopen("/System/Library/PrivateFrameworks/Weather.framework/Weather", RTLD_NOW);
    float (*ChanceOfRainWithHourlyForecasts)(NSArray*) = (float (*)(NSArray*))dlsym(weather, "_ChanceOfRainWithHourlyForecasts");
    
    if (ChanceOfRainWithHourlyForecasts != NULL) {
        NSLog(@"*** [InfoStats2 | DEBUG] :: WAHEY!");
        output = ChanceOfRainWithHourlyForecasts([self hourlyForecastsForCurrentLocation]);
    }
    
    //return ChanceOfRainWithHourlyForecasts([self hourlyForecastsForCurrentLocation]);
     return 0.0;*/
    
    if ([currentCity respondsToSelector:@selector(precipitationForecast)]) {
        return [currentCity precipitationForecast];
    } else {
        NSLog(@"[InfoStats2 | Weather] :: Current version of iOS does not support -currentChanceOfRain");
        return 0;
    }
}

-(int)currentlyFeelsLike {
    // On iOS 10 and higher, this is a WFTemperature
    if (deviceVersion >= 10.0) {
        WFTemperature *feelsLike = currentCity.feelsLike;
        return [[WeatherPreferences sharedPreferences] isCelsius] ? feelsLike.celsius : feelsLike.fahrenheit;
    } else {
        int temp = (int)currentCity.feelsLike;
    
        if (![[WeatherPreferences sharedPreferences] isCelsius])
            temp = ((temp*9)/5) + 32;
    
        return temp;
    }
}

-(NSString*)intTimeToString:(int)input {
    NSString *string = @"";
    if (input < 100) {
        string = [NSString stringWithFormat:@"00%d", input];
    } else if (input < 1000) {
        string = [NSString stringWithFormat:@"0%d", input];
    } else {
        string = [NSString stringWithFormat:@"%d", input];
    }
    
    char one, two, three, four;
    one = [string characterAtIndex:0];
    two = [string characterAtIndex:1];
    three = [string characterAtIndex:2];
    four = [string characterAtIndex:3];
    
    NSString *suffix = @"";
    
    // Convert to 12hr if required by current locale.
    // Yes, I know this is horrid. Oh well.
    if (![IS2System isDeviceIn24Time]) {
        
        if (one == '1' && two > '2') {
            one = '0';
            two -= 2;
            
            suffix = [IS2System translatedPMString];
        } else if (one == '2') {
            // Handle 20 and 21 first.
            if (two == '0') {
                one = '0';
                two = '8';
            } else if (two == '1') {
                one = '0';
                two = '9';
            } else {
                one = '1';
                two -= 2;
            }
            
            suffix = [IS2System translatedPMString];
        } else {
            suffix = [IS2System translatedAMString];
        }
        
    }
    
    // Split string, and insert :
    
    string = [NSString stringWithFormat:@"%c%c:%c%c%@", one, two, three, four, suffix];
    
    return string;
}

-(NSString*)sunsetTime {
    return [self intTimeToString:currentCity.sunsetTime];
}

-(NSString*)sunriseTime {
    return [self intTimeToString:currentCity.sunriseTime];
}

-(NSDate*)lastUpdateTime {
    return currentCity.updateTime;
}

-(double)currentLatitude {
    return currentCity.latitude;
}

-(double)currentLongitude {
    return currentCity.longitude;
}

-(float)currentPressure {
    return currentCity.pressure;
}

-(BOOL)isDay {
    return currentCity.isDay;
}

// Degrees
-(int)windDirection {
    return currentCity.windDirection;
}

-(NSArray*)dayForecastsForCurrentLocation {
    // The widget developer will be assuming this is the upcoming forecast for the week
    NSMutableArray *array = currentCity.dayForecasts;
    
    return array;
}

-(NSString*)dayForecastsForCurrentLocationJSON {
    NSMutableString *string = [@"[" mutableCopy];
    
    int i = 0;
    for (DayForecast *forecast in [[self dayForecastsForCurrentLocation] copy]) {
        i++;
        [string appendString:@"{"];
        
        [string appendFormat:@"\"dayNumber\":%d,", forecast.dayNumber];
        [string appendFormat:@"\"dayOfWeek\":%d,", forecast.dayOfWeek];
        [string appendFormat:@"\"condition\":%d,", forecast.icon];
        
        // Convert high and low to farenheit as needed
        int lattemp;
        if ([[WeatherPreferences sharedPreferences] isCelsius])
            lattemp = [forecast.high intValue];
        else
            lattemp = (([forecast.high intValue]*9)/5) + 32;
        [string appendFormat:@"\"high\":%d,", lattemp];
        
        if ([[WeatherPreferences sharedPreferences] isCelsius])
            lattemp = [forecast.low intValue];
        else
            lattemp = (([forecast.low intValue]*9)/5) + 32;
        [string appendFormat:@"\"low\":%d", lattemp];
        
        [string appendFormat:@"}%@", (i == [self dayForecastsForCurrentLocation].count ? @"" : @",")];
    }
    
    [string appendString:@"]"];
    
    return string;
}

-(NSString*)hourlyForecastsForCurrentLocationJSON {
    NSMutableString *string = [@"[" mutableCopy];
    
    int i = 0;
    for (HourlyForecast *forecast in [[self hourlyForecastsForCurrentLocation] copy]) {
        i++;
        [string appendString:@"{"];
        
        if ([forecast respondsToSelector:@selector(time24Hour)]) {
            [string appendFormat:@"\"time\":\"%@\",", forecast.time24Hour];
        } else {
            [string appendFormat:@"\"time\":\"%@\",", forecast.time];
        }
        
        // Convert temperature to farenheit
        NSString *detail;
        if ([forecast respondsToSelector:@selector(temperature)]) {
            detail = forecast.temperature;
        } else {
            detail = forecast.detail;
        }
        
        int lattemp;
        if ([[WeatherPreferences sharedPreferences] isCelsius])
            lattemp = [detail intValue];
        else
            lattemp = (([detail intValue]*9)/5) + 32;
        
        [string appendFormat:@"\"temperature\":%d,", lattemp];
        [string appendFormat:@"\"condition\":%d,", forecast.conditionCode];
        [string appendFormat:@"\"percentPrecipitation\":%d", (int)forecast.percentPrecipitation];
        
        [string appendFormat:@"}%@", (i == [self hourlyForecastsForCurrentLocation].count ? @"" : @",")];
    }
    
    [string appendString:@"]"];
    
    return string;
}

-(NSArray*)hourlyForecastsForCurrentLocation {
    NSMutableArray *array = currentCity.hourlyForecasts;
    
    return array;
}

@end
