//
//  IS2Weather.m
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import "IS2Weather.h"
#import "IS2WeatherProvider.h"

static NSMutableSet *weatherUpdateBlockQueue;

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

+(int)currentWindSpeed {
    return [[IS2WeatherProvider sharedInstance] currentWindSpeed];
}

+(int)currentDewPoint {
    return [[IS2WeatherProvider sharedInstance] currentDewPoint];
}

+(int)currentHumidity {
    return [[IS2WeatherProvider sharedInstance] currentHumidity];
}

+(NSArray*)dayForecastsForCurrentLocation {
    return [[IS2WeatherProvider sharedInstance] dayForecastsForCurrentLocation];
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

+(void)updateWeatherWithCallback:(void (^)(void))callbackBlock {
    if (!weatherUpdateBlockQueue) {
        weatherUpdateBlockQueue = [NSMutableSet set];
    }
    
    if (callbackBlock)
        [weatherUpdateBlockQueue addObject:callbackBlock];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if (![[IS2WeatherProvider sharedInstance] isUpdating]) {
            // Update weather, and then call blocks for updated weather.
            [[IS2WeatherProvider sharedInstance] updateWeatherWithCallback:^{
                for (void (^block)() in weatherUpdateBlockQueue) {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [block invoke]; // Runs all the callbacks whom requested a weather update.
                    });
                }
            }];
        }
    });
}

@end
