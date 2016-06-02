//
//  IS2Weather.h
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import <Foundation/Foundation.h>

/** IS2Weather is used to access a wide variety of weather data directly sourced from Apple's weather framework. It communicates with the daemon provided with InfoStats2 to update data in the background whenever a call to update occurs.
 
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

/** Sets the time interval after which weather data auto-updating is performed. By default, this is set to 30 minutes, though will be effectively off when no widgets are added.<br/><br/>If another client of the InfoStats2 API has requested a shorter time interval, that shorter interval will be used instead. You will be notified of new data being available via the callback specified with <i>registerForWeatherUpdatesWithIdentifier:andCallback:</i>
 
 @param interval The interval to be requested for weather data auto-updates.<br/><br/>Available values:<br/>10 - Update every 10 minutes<br/>15 - Update every 15 minutes<br/>20 - Update every 20 minutes<br/>30 - Update every 30 minutes<br/>40 - Update every 40 minutes<br/>50 - Update every 50 minutes<br/>60 - Update every 1 hour<br/>120 - Update every 2 hours
 @param requester A unique identifier used to identify your code as requesting a particular interval. It is recommended to use reverse DNS notation, such as "com.foo.bar".
 */
+(void)setWeatherUpdateTimeInterval:(int)interval forRequester:(NSString*)requester;

/** Removes your code as requesting a particular auto-update interval, as detailed in <i>setWeatherUpdateTimeInterval:forRequester:</i>. This should be called once your code is unloaded.
 @param requester A unique identifier used to identify your code as requesting a particular interval. It is recommended to use reverse DNS notation, such as "com.foo.bar".
 */
+(void)removeRequesterForWeatherTimeInterval:(NSString*)requester;

/** Call this method to manually update the current weather data; your code will be notified when this update is completed via the callback block set in <i>-registerForWeatherUpdatesWithIdentifier:</i>.
 */
+(void)updateWeather;

/** The last time the currently selected city in Apple's weather application was updated.
 @return Last update time in the format: hours:minutes (00:00), automatically converted between 24hr and 12hr dependant on user's settings
 */
+(NSString*)lastUpdateTime;

/** @name Locale-specific Preferences
 */

/** A boolean specifying whether the returned weather data is in Celsius or Fahrenheit.
 @return Whether weather data is in Celsius or Fahrenheit
 */
+(BOOL)isCelsius;

/** A boolean specifying whether the returned weather data gives wind speeds in mph or km/h.
 @return Whether wind data is measured in mph or km/h.
 */
+(BOOL)isWindSpeedMph;
+(NSString*)translatedWindSpeedUnits;

/** @name Current Data
 */

/** Gives the current location used for weather data. This will be either the local city if Location Services is enabled, or the first city in Apple's Weather app otherwise.
 @return The current location for weather data
 */
+(NSString*)currentLocation;

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

/** Gives a longer string detailing general conditions for the current day; an example of this output can be seen in the Notification Center. Please note that this functionality is available for iOS 7+; for iOS 6, this will simply return the current condition.
 @return A longer description of the day's conditions.
 */
+(NSString*)naturalLanguageDescription;

/** Gives the high temperature for the current day.
 @return Today's high temperature
 */
+(int)highForCurrentDay;

/** Gives the low temperature for the current day.
 @return Today's low temperature
 */
+(int)lowForCurrentDay;

/** The current wind speed, automatically converted between mph and km/h dependant on the user's locale settings
 @return The current wind speed
 */
+(int)currentWindSpeed;

/** The current wind direction, measured in degrees from 0-360, with 0 being North and 180 being South.
 @return Wind direction in degrees
 */
+(int)currentWindDirection;

/** The current wind chill for today
 @return Wind chill, in Celsius or Farenheit dependant on user settings
 */
+(int)currentWindChill;

/** The temperature required for dew to form today.
 @return Currrent dew point
 */
+(int)currentDewPoint;

/** The current air humidity
 @return The current humidity as a percentage, 0-100.
 */
+(int)currentHumidity;

/** Percentage representing the quality visibility is on the current day
 @return Visibility, measured in percent 0-100
 */
+(int)currentVisibilityPercent;

/** Current chance of rain, as a percentage between 0-100
 @return Current chance of rain
 */
+(int)currentChanceOfRain;

/** The temperature it feels like, taking into account wind chill etc.
 @return Current "feels like" temperature; this is automatically converted between Celsius and Farenheit
 */
+(int)currentlyFeelsLike;

/** The current pressure in millibars (typically around 900-1100)
 @return Current atmospheric pressure
 */
+(CGFloat)currentPressure;

/** The time sunset will occur, in the format hours:minutes (eg 16:23). This is automatically converted between 24hr and 12hr dependant on user settings
 @return Formatted sunset time
 */
+(NSString*)sunsetTime;

/** The time sunrise will occur, in the format hours:minutes (eg 16:23). This is automatically converted between 24hr and 12hr dependant on user settings
 @return Formatted sunrise time
 */
+(NSString*)sunriseTime;

/** The current latitude of the location used for weather data; either the local area if Location Services are enabled, or the first city in Apple's Weather app if not.
 @return Current latitude
 */
+(CGFloat)currentLatitude;

/** The current longitude of the location used for weather data; either the local area if Location Services are enabled, or the first city in Apple's Weather app if not.
 @return Current longitude
 */
+(CGFloat)currentLongitude;

/** @name Forecasts */

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

@end
