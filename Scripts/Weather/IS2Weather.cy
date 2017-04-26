/*
 * All data present in IS2Weather can be accessed like so:
 * 
 * var thingYouWant = IS2Weather.<insert_thing_here>();
 *
 * You will need to setup IS2Weather with a function to call whenever data is updated by InfoStats 2.
 * To do so, in the first function that you've defined at either <body onload="firstFunction()"> or at
 * the bottom of your <body> tag before </body>, you'll want to call the following function:
 *
 * IS2Weather.init(<function_to_call_when_data_updates>, <weather_update_interval>);
 *
 * Where <function_to_call_when_data_updates> is typed without the usual () following it.
 * In addition, <weather_update_interval> can one of the following values:
 *    10 - Update every 10 minutes
 *    15 - Update every 15 minutes
 *    20 - Update every 20 minutes
 *    30 - Update every 30 minutes
 *    40 - Update every 40 minutes
 *    50 - Update every 50 minutes
 *    60 - Update every 1 hour
 *    120 - Update every 2 hours
 *
 * For further documentation on the data provided here, make sure to check the IS2 documentation found at
 * http://incendo.ws/projects/InfoStats2/Classes/IS2Weather.html
 * Each IS2 function used in this script is documented there.
*/

var IS2Weather = {
  // Setup.
  init: function(weatherUpdatedCallback, updateTimeInterval) {
    [IS2Weather registerForWeatherUpdatesWithIdentifier:widgetIdentifier andCallback:^ void () {
      weatherUpdatedCallback();
    }];
    
    // Now, we set the update time.
    [IS2Weather setWeatherUpdateTimeInterval:updateTimeInterval forRequester:widgetIdentifier];
  },
  // helper function, don't call manually unless you really know what you're doing.
  onunload : function() {
    [IS2Weather unregisterForUpdatesWithIdentifier:widgetIdentifier];
    [IS2Weather removeRequesterForWeatherTimeInterval:widgetIdentifier];
  },

  // Locale-specific Preferences
  getIsCelsius: function() {
    return [IS2Weather isCelsius];
  },
  getIsWindSpeedMPH: function() {
    return [IS2Weather isWindSpeedMph];
  },
  
  // Info about the location weather data is returned for
  getLocation: function() {
    return [IS2Weather currentLocation];
  },
  getLatitude: function() {
    return [IS2Weather currentLatitude];
  },
  getLongitude: function() {
    return [IS2Weather currentLongitude];
  },
  
  // Current weather data
  getTemperature: function() {
    return [IS2Weather currentTemperature];
  },
  getConditionCode: function() {
    return [IS2Weather currentCondition];
  },
  getConditionCodeAsString: function() {
    return [IS2Weather currentConditionAsString];
  },
  getDescriptionOfCondition: function() {
    return [IS2Weather naturalLanguageDescription];
  },
  getHigh: function() {
    return [IS2Weather highForCurrentDay];
  },
  getLow: function() {
    return [IS2Weather lowForCurrentDay];
  },
  getWindSpeed: function() {
    return [IS2Weather currentWindSpeed];
  },
  getWindDirectionAsCardinal: function() {
    return [IS2Weather currentWindDirection];
  },
  getWindChill: function() {
    return [IS2Weather currentWindChill];
  },
  getDewPoint: function() {
    return [IS2Weather currentDewPoint];
  },
  getHumidity: function() {
    return [IS2Weather currentHumidity];
  },
  getCurrentVisibilityInPercent: function() {
    return [IS2Weather currentVisibilityPercent];
  },
  getChanceOfRain: function() {
    return [IS2Weather currentChanceOfRain];
  },
  getFeelsLike: function() {
    return [IS2Weather currentlyFeelsLike];
  },
  getPressureInMillibars: function() {
    return [IS2Weather currentPressure];
  },
  getSunsetTime: function() {
    return [IS2Weather sunsetTime];
  },
  getSunriseTime: function() {
    return [IS2Weather sunriseTime];
  },

  // Forecast data - these are both returned as JavaScript arrays
  getHourlyForecastsArray: function() {
    return JSON.parse("" + [IS2Weather hourlyForecastsForCurrentLocationJSON]);
  },
  getDailyForecastsArray: function() {
    return JSON.parse("" + [IS2Weather dayForecastsForCurrentLocationJSON]);
  }
};