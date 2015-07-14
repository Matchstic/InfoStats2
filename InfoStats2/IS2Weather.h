//
//  IS2Weather.h
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import <Foundation/Foundation.h>

@interface IS2Weather : NSObject

+(int)currentTemperature;
+(int)currentCondition;
+(NSString*)currentConditionAsString;
+(int)highForCurrentDay;
+(int)lowForCurrentDay;

+(int)currentWindSpeed;
+(NSString*)translatedWindSpeedUnits;
+(BOOL)isWindSpeedMph;

+(NSString*)currentLocation;
+(int)currentDewPoint;
+(int)currentHumidity;
+(int)currentWindChill;
+(int)currentVisibilityPercent;
+(int)currentChanceOfRain;
+(int)currentlyFeelsLike;
+(NSString*)sunsetTime;
+(NSString*)sunriseTime;
+(NSString*)lastUpdateTime;
+(NSArray*)hourlyForecastsForCurrentLocation;
+(NSArray*)dayForecastsForCurrentLocation;
+(BOOL)isWeatherUpdating;
+(BOOL)isCelsius;
+(void)updateWeatherWithCallback:(void (^)(void))callbackBlock;

@end
