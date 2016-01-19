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

static IS2WorkaroundDictionary *weatherUpdateBlockQueueTest;

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

+(int)highForCurrentDay {
    return [[IS2WeatherProvider sharedInstance] highForCurrentDay];
}

+(int)lowForCurrentDay {
    return [[IS2WeatherProvider sharedInstance] lowForCurrentDay];
}

// Check for differences in mph and kph
+(int)currentWindSpeed {
    return [[IS2WeatherProvider sharedInstance] currentWindSpeed];
}

// Check for celsusis and farenheit
+(int)currentDewPoint {
    return [[IS2WeatherProvider sharedInstance] currentDewPoint];
}

// check is percentage
+(int)currentHumidity {
    return [[IS2WeatherProvider sharedInstance] currentHumidity];
}

// Check for celsusis and farenheit
+(int)currentWindChill {
    return [[IS2WeatherProvider sharedInstance] currentWindChill];
}

// Check is degrees
+(int)currentWindDirection {
    return [[IS2WeatherProvider sharedInstance] windDirection];
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
    }
}

+(void)unregisterForUpdatesWithIdentifier:(NSString*)identifier {
    [weatherUpdateBlockQueueTest removeObjectForKey:identifier];
}

+(void)updateWeather {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if (![[IS2WeatherProvider sharedInstance] isUpdating]) {
            // Update weather, and then call blocks for updated weather.
            [[IS2WeatherProvider sharedInstance] updateWeatherWithCallback:^{
                for (void (^block)() in [weatherUpdateBlockQueueTest allValues]) {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        block(); // Runs all the callbacks whom requested a weather update.
                    });
                }
            }];
        }
    });
}

+(BOOL)isCelsius {
    return [[IS2WeatherProvider sharedInstance] isCelsius];
}

@end
