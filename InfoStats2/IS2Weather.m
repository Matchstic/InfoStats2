//
//  IS2Weather.m
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import "IS2Weather.h"
#import "IS2WeatherProvider.h"
#import "IS2WorkaroundDictionary.h"
#import "IS2Extensions.h"

#define DEFAULT_WEATHER_UPDATE_INTERVAL 30

static IS2WorkaroundDictionary *weatherUpdateBlockQueueTest;
static NSTimer *autoUpdateTimer;
static NSMutableDictionary *requesters;

static inline void buildRequestersDictionary() {
    requesters = [NSMutableDictionary dictionary];
    
    [requesters setObject:[NSMutableArray array] forKey:@"k10"];
    [requesters setObject:[NSMutableArray array] forKey:@"k15"];
    [requesters setObject:[NSMutableArray array] forKey:@"k20"];
    [requesters setObject:[NSMutableArray array] forKey:@"k30"];
    [requesters setObject:[NSMutableArray array] forKey:@"k40"];
    [requesters setObject:[NSMutableArray array] forKey:@"k50"];
    [requesters setObject:[NSMutableArray array] forKey:@"k60"];
    [requesters setObject:[NSMutableArray array] forKey:@"k120"];
}

@implementation IS2Weather

+(int)currentTemperature {
    return [[IS2WeatherProvider sharedInstance] currentTemperature];
}

+(NSString*)currentLocation {
    return [[IS2WeatherProvider sharedInstance] currentLocation];
}

+(int)currentCondition {
    return [[IS2WeatherProvider sharedInstance] currentCondition];
}

+(NSString*)currentConditionAsString {
    return [[IS2WeatherProvider sharedInstance] currentConditionAsString];
}

+(NSString*)naturalLanguageDescription {
    return [[IS2WeatherProvider sharedInstance] naturalLanguageDescription];
}

+(int)highForCurrentDay {
    return [[IS2WeatherProvider sharedInstance] highForCurrentDay];
}

+(int)lowForCurrentDay {
    return [[IS2WeatherProvider sharedInstance] lowForCurrentDay];
}

// Conversion between mph and kph done in IS2WeatherProvider
+(int)currentWindSpeed {
    return [[IS2WeatherProvider sharedInstance] currentWindSpeed];
}

// Check for celsius and farenheit
+(int)currentDewPoint {
    return [[IS2WeatherProvider sharedInstance] currentDewPoint];
}

+(int)currentHumidity {
    return [[IS2WeatherProvider sharedInstance] currentHumidity];
}

// Check for celsusis and farenheit
+(int)currentWindChill {
    return [[IS2WeatherProvider sharedInstance] currentWindChill];
}

+(int)currentWindDirection {
    return [[IS2WeatherProvider sharedInstance] windDirection];
}

+(BOOL)isWindSpeedMph {
    return [[IS2WeatherProvider sharedInstance] isWindSpeedMph];
}

+(int)currentVisibilityPercent {
    return [[IS2WeatherProvider sharedInstance] currentVisibilityPercent];
}

+(int)currentChanceOfRain {
    return [[IS2WeatherProvider sharedInstance] currentChanceOfRain];
}

+(int)currentlyFeelsLike {
    return [[IS2WeatherProvider sharedInstance] currentlyFeelsLike];
}

+(NSString*)sunsetTime {
    return [[IS2WeatherProvider sharedInstance] sunsetTime];
}

+(NSString*)sunriseTime {
    return [[IS2WeatherProvider sharedInstance] sunriseTime];
}

+(NSString*)lastUpdateTime {
    // Convert NSDate into NSString - HH:MM
    NSDate *date = [[IS2WeatherProvider sharedInstance] lastUpdateTime];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24Hour = amRange.location == NSNotFound && pmRange.location == NSNotFound;
    
    if (is24Hour)
        formatter.dateFormat = @"HH:mm";
    else
        formatter.dateFormat = @"hh:mm";
    
    dateString = [formatter stringFromDate:date];
    
    // Remove the preceeding 0 if needed for 12hr
    if (!is24Hour) {
        // Check the value of the first character
        if ([dateString hasPrefix:@"0"])
            dateString = [dateString substringFromIndex:1];
    }
    
    return dateString;
}

+(CGFloat)currentLatitude {
    return [[IS2WeatherProvider sharedInstance] currentLatitude];
}

+(CGFloat)currentLongitude {
    return [[IS2WeatherProvider sharedInstance] currentLongitude];
}

+(CGFloat)currentPressure {
    return [[IS2WeatherProvider sharedInstance] currentPressure];
}

+(NSArray*)dayForecastsForCurrentLocation {
    return [[IS2WeatherProvider sharedInstance] dayForecastsForCurrentLocation];
}

+(NSString*)dayForecastsForCurrentLocationJSON {
    return [[IS2WeatherProvider sharedInstance] dayForecastsForCurrentLocationJSON];
}

+(NSString*)hourlyForecastsForCurrentLocationJSON {
    return [[IS2WeatherProvider sharedInstance] hourlyForecastsForCurrentLocationJSON];
}

+(NSArray*)hourlyForecastsForCurrentLocation {
    return [[IS2WeatherProvider sharedInstance] hourlyForecastsForCurrentLocation];
}

+(BOOL)isWeatherUpdating {
    return [[IS2WeatherProvider sharedInstance] isUpdating];
}

+(NSString*)translatedWindSpeedUnits {
    return [[IS2WeatherProvider sharedInstance] translatedWindSpeedUnits];
}

+(void)registerForWeatherUpdatesWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock {
    if (!weatherUpdateBlockQueueTest) {
        weatherUpdateBlockQueueTest = [IS2WorkaroundDictionary dictionary];
    }
    
    if (callbackBlock && identifier) {
        [weatherUpdateBlockQueueTest addObject:callbackBlock forKey:identifier];
        // Auto-update when a new widget adds itself.
        [self setWeatherUpdateTimeInterval:DEFAULT_WEATHER_UPDATE_INTERVAL forRequester:identifier];
    }
}

+(void)unregisterForUpdatesWithIdentifier:(NSString*)identifier {
    [weatherUpdateBlockQueueTest removeObjectForKey:identifier];
    [self removeRequesterForWeatherTimeInterval:identifier];
}

+(void)setWeatherUpdateTimeInterval:(int)interval forRequester:(NSString*)requester {
    if (!requesters) {
        buildRequestersDictionary();
    }
    
    NSLog(@"[InfoStats2 | Weather] :: Adding update requester %@ for interval %d", requester, interval);
    
    NSString *key = [NSString stringWithFormat:@"k%d", interval];
    
    if (![[requesters allKeys] containsObject:key]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"InfoStats2 :: Debug" message:[NSString stringWithFormat:@"Invalid interval %d provided for requester %@", interval, requester] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    int previousRequester = [self currentlyMostAccurateRequester];
    
    // if requester is already present, remove it from it's existing thing.
    if ([self arrayForRequester:requester]) {
        [self removeRequesterForWeatherTimeInterval:requester];
    }
    
    NSMutableArray *requests = [requesters objectForKey:key];
    [requests addObject:requester];
    [requesters setObject:requests forKey:key];
    
    // Just now need to modify the timer's duration to suit the new time!
    int currentRequester = [self currentlyMostAccurateRequester];
    if (currentRequester != -1) {
        // Do an update now, and reset the timer.
        
        // Hold up a second. We only need to do the weather update if the previous requester was -1.
        // Else, we end up chowing down on battery usage.
        if (previousRequester == -1) {
            [self updateWeather];
        }
        
        [autoUpdateTimer invalidate];
        autoUpdateTimer = nil;
        
        NSLog(@"[InfoStats2 | Weather] :: Setting update requester to %d", currentRequester*60);
        autoUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:currentRequester*60 target:self selector:@selector(_timerUpdateWeather:) userInfo:nil repeats:YES];
    } else {
        // Invalidate timer
        [autoUpdateTimer invalidate];
        autoUpdateTimer = nil;
    }
}

+(NSMutableArray*)arrayForRequester:(NSString*)requester {
    NSMutableArray *array;
    
    for (NSMutableArray *arr in [requesters allValues]) {
        if ([arr containsObject:requester]) {
            array = arr;
            break;
        }
    }
    
    return array;
}

+(int)currentlyMostAccurateRequester {
    // 10 mins
    if ([[requesters objectForKey:@"k10"] count] > 0) {
        return 10;
    }
    
    // 15 mins
    if ([[requesters objectForKey:@"k15"] count] > 0) {
        return 15;
    }
    
    // 20 mins
    if ([[requesters objectForKey:@"k20"] count] > 0) {
        return 20;
    }
    
    // 30 mins
    if ([[requesters objectForKey:@"k30"] count] > 0) {
        return 30;
    }
    
    // 40 mins
    if ([[requesters objectForKey:@"k40"] count] > 0) {
        return 40;
    }
    
    // 50 mins
    if ([[requesters objectForKey:@"k50"] count] > 0) {
        return 50;
    }
    
    // 60 mins
    if ([[requesters objectForKey:@"k60"] count] > 0) {
        return 60;
    }
    
    // 120 mins
    if ([[requesters objectForKey:@"k120"] count] > 0) {
        return 120;
    }
    
    // Otherwise, manual only!
    return -1;
}

+(void)removeRequesterForWeatherTimeInterval:(NSString*)requester {
    NSLog(@"[InfoStats2 | Weather] :: DEBUG :: Removing update requester %@", requester);
    
    NSMutableArray *currentArray = [self arrayForRequester:requester];
    
    // Get the key for this array!
    NSString *key = @"";
    for (NSString *key2 in [requesters allKeys]) {
        NSMutableArray *arr = [requesters objectForKey:key];
        
        if ([arr containsObject:requester]) {
            key = key2;
            break;
        }
    }
    
    [currentArray removeObject:requester];
    
    if (currentArray)
        [requesters setObject:currentArray forKey:key];
    else
        [requesters setObject:[NSMutableArray array] forKey:key];
    
    // Just now need to modify the timer's duration to suit the new time!
    int currentRequester = [self currentlyMostAccurateRequester];
    if (currentRequester != -1) {
        // Do an update now, and reset the timer.
        // Wait, no. Don't do this. There is absolutely no need to update the weather at this point, and it serves
        // to cause battery drainage. Ya moose.
        // [self updateWeather];
        
        [autoUpdateTimer invalidate];
        autoUpdateTimer = nil;
        
        NSLog(@"[InfoStats2 | Weather] :: Setting update requester to %d", currentRequester*60);
        autoUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:currentRequester*60 target:self selector:@selector(_timerUpdateWeather:) userInfo:nil repeats:YES];
    } else {
        // Invalidate timer
        [autoUpdateTimer invalidate];
        autoUpdateTimer = nil;
    }
}

+(void)_timerUpdateWeather:(id)sender {
    NSLog(@"[InfoStats2 | Weather] :: Auto-update timer fired!");
    [self updateWeather];
}

+(void)updateWeather {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if (![[IS2WeatherProvider sharedInstance] isUpdating]) {
            // Update weather, and then call blocks for updated weather.
            [[IS2WeatherProvider sharedInstance] updateWeatherWithCallback:^{
                NSLog(@"[InfoStats2 | Weather] :: Running through blocks");
                
                for (void (^block)() in [weatherUpdateBlockQueueTest allValues]) {
                    @try {
                        [[IS2Private sharedInstance] performSelectorOnMainThread:@selector(performBlockOnMainThread:) withObject:block waitUntilDone:NO];
                    } @catch (NSException *e) {
                        NSLog(@"[InfoStats2 | Weather] :: Failed to update callback, with exception: %@", e);
                    } @catch (...) {
                        NSLog(@"[InfoStats2 | Weather] :: Failed to update callback, with unknown exception");
                    }
                }
            }];
        }
    });
}

+(BOOL)isCelsius {
    return [[IS2WeatherProvider sharedInstance] isCelsius];
}

+(BOOL)isDay {
    return [[IS2WeatherProvider sharedInstance] isDay];
}

@end
