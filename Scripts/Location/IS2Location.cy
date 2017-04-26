/*
 * All data present in IS2Location can be accessed like so:
 * 
 * var thingYouWant = IS2Location.<insert_thing_here>();
 *
 * You will need to setup IS2Location with a function to call whenever data is updated by InfoStats 2.
 * To do so, in the first function that you've defined at either <body onload="firstFunction()"> or at
 * the bottom of your <body> tag before </body>, you'll want to call the following function:
 *
 * IS2Location.init(<function_to_call_when_data_updates>, <distance_interval>, <update_accuracy>);
 *
 * Where <function_to_call_when_data_updates> is typed without the usual () following it.
 * In addition, <distance_interval> can one of the following values:
 *    1 - Update every 10 meters moved (walking or cycling)
 *    2 - Update every 100 meters (driving or other such transport)
 *    3 - Update every 500 meters
 *    4 - Update every 1 kilometer (best for weather data)
 *
 * And <update_accuracy> is one of the following values:
 *     1 - Satellite navigation quality (GPS and additional sensors)
 *     2 - Satellite navigation quality (GPS only)
 *     3 - Within 10 meters of the user
 *     4 - Within 100 meters
 *     5 - Within 1 kilometer
 *     6 - Within 3 kilometers
 *
 * For further documentation on the data provided here, make sure to check the IS2 documentation found at
 * http://incendo.ws/projects/InfoStats2/Classes/IS2Location.html
 * Each IS2 function used in this script is documented there.
*/

var IS2Location = {
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Setup
  init: function(locationDataCallback, distanceInterval, updateAccuracy) {
    [IS2Location registerForLocationNotificationsWithIdentifier:widgetIdentifier andCallback:^ void () {
      locationDataCallback();
    }];
    
    [IS2Location setLocationUpdateDistanceInterval:distanceInterval forRequester:widgetIdentifier];
    [IS2Location setLocationUpdateAccuracy:updateAccuracy forRequester:widgetIdentifier];
  },
  // Don't call this manually unless you know really what you're doing!
  onunload: function() {
    [IS2Location unregisterForNotificationsWithIdentifier:widgetIdentifier];
    [IS2Location removeRequesterForLocationDistanceInterval:widgetIdentifier];
    [IS2Location removeRequesterForLocationAccuracy:widgetIdentifier];
  },
  
  // Force a manual refresh of location data. This shouldn't be needed, but is present in the event it is.
  forceManualRefreshOfData: function() {
    [IS2Location requestUpdateToLocationData];
  },

  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Data Access.
  
  getIsLocationServicesEnabled: function() {
    return [IS2Location isLocationServicesEnabled];
  },
  getLatitude: function() {
    return [IS2Location currentLatitude];
  },
  getLongitude: function() {
    return [IS2Location currentLongitude];
  },
  getHouseNumber: function() {
    return [IS2Location houseNumberForCurrentLocation];
  },
  getStreet: function() {
    return [IS2Location streetForCurrentLocation];
  },
  getPostCode: function() {
    return [IS2Location postCodeForCurrentLocation];
  },
  getNeighbourhood: function() {
    return [IS2Location neighbourhoodForCurrentLocation];
  },
  getCity: function() {
    return [IS2Location cityForCurrentLocation];
  },
  getCounty: function() {
    return [IS2Location countyForCurrentLocation];
  },
  getState: function() {
    return [IS2Location stateForCurrentLocation];
  },
  getCountry: function() {
    return [IS2Location countryForCurrentLocation];
  },
  getCountryISOCode: function() {
    return [IS2Location ISOCountryCodeForCurrentLocation];
  }
};