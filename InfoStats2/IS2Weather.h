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

/** Sets a block to be called whenever weather data changes. The identifier must be unique string; it is recommended to use reverse DNS notation, such as "com.foo.bar".
 @param identifier The identifier associated with your callback
 @param callbackBlock The block to call once data changes
 */
+(void)registerForWeatherUpdatesWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock;

/** The inverse of registering for notifications. This must be called when your code is unloaded, else a thermonulcear detonation will occur on the palm of your hand.
 @param identifier The identifier associated with your callback
 */
+(void)unregisterForUpdatesWithIdentifier:(NSString*)identifier;

/** Call this method to update the current weather data; your code will be notified when this update is completed via the callback block set in <i>-registerForWeatherUpdatesWithIdentifier:</i>.
 */
+(void)updateWeather;

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

/** Gives an array of HourlyForecast objects ( https://github.com/nst/iOS-Runtime-Headers/blob/master/PrivateFrameworks/Weather.framework/HourlyForecast.h ) representing the forecast for the next few hours. It's not recommendeded to use this method if you are iterfacing with this API via JavaScript.
 @return An array of hourly forecasts
 */
+(NSArray*)hourlyForecastsForCurrentLocation;

/** Gives JSON representing hourly forecasts.
 @return JSON representation of the hourly forecast, in the form of:<code><br/>
 [<br/>
 &emsp;{<br/>
 &emsp;&emsp;"time": "15:00", (Time is formatted as per the user's locale)<br/>
 &emsp;&emsp;"condition": 30, (The Yahoo.com condition code for this day)<br/>
 &emsp;&emsp;"temperature": 1,<br/>
 &emsp;&emsp;"percentPrecipitation": 30<br/>
 &emsp;},<br/>
 &emsp;{<br/>
 &emsp;&emsp;...<br/>
 &emsp;}<br/>
 ]<br/></code>
 */
+(NSString*)hourlyForecastsForCurrentLocationJSON;

/** Gives an array of daily forecasts. These are in the form of DayForecast objects ( https://github.com/nst/iOS-Runtime-Headers/blob/master/PrivateFrameworks/Weather.framework/DayForecast.h ) - It's not recommendeded to use this method if you are iterfacing with this API via JavaScript.
 @return An array of daily forecasts
 */
+(NSArray*)dayForecastsForCurrentLocation;

/** Gives JSON representing daily forecasts.
 @return JSON representation of the daily forecast, in the form of:<code><br/>
 [<br/>
 &emsp;{<br/>
 &emsp;&emsp;"dayNumber": 1, (Index of the day in the data)<br/>
 &emsp;&emsp;"dayOfWeek": 3, (Sunday is treated as day 1, with Saturday as day 7)<br/>
 &emsp;&emsp;"condition": 30, (The Yahoo.com condition code for this day)<br/>
 &emsp;&emsp;"high": 15,<br/>
 &emsp;&emsp;"low": 10<br/>
 &emsp;},<br/>
 &emsp;{<br/>
 &emsp;&emsp;...<br/>
 &emsp;}<br/>
 ]<br/></code>
 */
+(NSString*)dayForecastsForCurrentLocationJSON;

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
