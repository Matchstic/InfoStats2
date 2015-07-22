//
//  IS2Weather.h
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import <Foundation/Foundation.h>

/** IS2Weather is used to access a wide variety of weather data directly sourced from Apple's weather framework. It communicates with the daemon provided with InfoStats 2 to update data in the background whenever a call to update occurs.
 
 On each update, if the user has enabled Location Services then a new location will be found before updating data. This ensures that the most accurate data is returned.
 
 If Location Services is not enabled, then the first city in the Weather app will be used as a basis for data retrieval.
 */

@interface IS2Weather : NSObject

/** @name Updating Data
 */

/** This method is used to update weather data asynchrously, and then notify your code that an update has occured. If you call this method whilst data is already updating, your code will be notified when the current update finishes.
 @param callbackBlock The code to call once updating finishes
 */
+(void)updateWeatherWithCallback:(void (^)(void))callbackBlock;



/** @name Locale-specific Preferences
 */

/** A boolean specifying whether the returned weather data is in celsius or fahrenheit.
 @return Whether weather data is in celsius or fahrenheit
 */
+(BOOL)isCelsius;

// Yeah I ain't documenting these yet
+(BOOL)isWindSpeedMph;
+(NSString*)translatedWindSpeedUnits;

/** @name Data Retrieval
 */

/** Gives the current temperature.
 @return The current temperature
 */
+(int)currentTemperature;

/** Gives the appropriate Yahoo.com weather code for the current weather condition.
 @return The current weather condition
 */
+(int)currentCondition;

/** Gives the appropriate Yahoo.com weather code as a human-readable string. This is automatically translated for you.
 @return The current (readable) weather condition
 */
+(NSString*)currentConditionAsString;

/** Gives the high temperature for the current day.
 @return Today's high temperature
 */
+(int)highForCurrentDay;

/** Gives the low temperature for the current day.
 @return Today's low temperature
 */
+(int)lowForCurrentDay;

/** Gives current wind speed. This is automatically converted between mph and kph for you.
 @return The current wind speed
 */
+(int)currentWindSpeed;

/** Gives the appropriate Yahoo.com weather code for the current weather condition.
 @return The current weather condition
 */
+(NSString*)currentLocation;

/** Gives an array of hourly forecasts. These are in the form of HourlyForecast objects; see https://github.com/nst/iOS-Runtime-Headers/blob/master/PrivateFrameworks/Weather.framework/HourlyForecast.h for the header for these.
 @return An array of hourly forecasts
 */
+(NSArray*)hourlyForecastsForCurrentLocation;

/** Gives an array of daily forecasts. These are in the form of DayForecast objects; see https://github.com/nst/iOS-Runtime-Headers/blob/master/PrivateFrameworks/Weather.frameworkDayForecast.h for the header for these.
 @return An array of daily forecasts
 */
+(NSArray*)dayForecastsForCurrentLocation;

//+(int)currentDewPoint;
//+(int)currentHumidity;
//+(int)currentWindChill;
//+(int)currentVisibilityPercent;
//+(int)currentChanceOfRain;
//+(int)currentlyFeelsLike;
//+(NSString*)sunsetTime;
//+(NSString*)sunriseTime;
//+(NSString*)lastUpdateTime;

@end
