//
//  IS2Location.h
//  InfoStats2
//
//  Created by Matt Clarke on 23/07/2015.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kManualUpdate,
    kTurnByTurn,
    k100Meters,
    k500Meters,
    k1Kilometer
} IS2LocationUpdateInterval;

/** IS2Location allows for querying data about the user's current location, and also to be notified when the user changes location if so required. 
 */

@interface IS2Location : NSObject

/** @name Setup
 */

/** Sets a block to be called whenever location data changes. The identifier must be unique string; it is recommended to use reverse DNS notation, such as "com.foo.bar".
 @param identifier The identifier associated with your callback
 @param callbackBlock The block to call once data changes
 */
+(void)registerForLocationNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock;

/** The inverse of registering for notifications. This must be called when your code is unloaded, else your device may play Disney's Let It Go at the worst possible moments.
 @param identifier The identifier associated with your callback
 */
+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier;

/** @name Requesting data
 */

/** Requests an immediate update to location data. Please note that this will not notify your callback for location changes if Location Services is disabled.
 */
+(void)requestUpdateToLocationData;

/** Sets the distance interval the user must travel before a location data update is performed. By default, this is set to "manual updating", whereupon location data is only updated after calling <i>requestUpdateToLocationData</i>.<br/><br/>If another client of the InfoStats2 API has requested a more fine-grained distance interval, that more fine-grained interval will be used instead.
 
 @param interval The interval to be requested for location data updates.<br/><br/>Available values:<br/>1 - Update every 10 meters moved (walking or cycling)<br/>2 - Update every 100 meters (driving or other such transport)<br/>3 - Update every 500 meters<br/>4 - Update every 1 kilometer (best for weather data)
 @param requester A unique identifier used to identify your code as requesting a particular interval. It is recommended to use reverse DNS notation, such as "com.foo.bar".
 */
+(void)setLocationUpdateDistanceInterval:(int)interval forRequester:(NSString*)requester;

/** Removes your code as requesting a particular update interval, as detailed in <i>setLocationUpdateDistanceInterval:forRequester:</i>. This must be called once your code is unloaded, else location data will continue to be updated, thus draining battery.
 @param requester A unique identifier used to identify your code as requesting a particular interval. It is recommended to use reverse DNS notation, such as "com.foo.bar".
 */
+(void)removeRequesterForLocationDistanceInterval:(NSString*)requester;

/** Sets the accuracy of the resulting location data. Please be aware though that the higher the accuracy, the faster the battery will drain. By default, this will be set to an accuracy of within 100 meters of the user.<br/><br/>If another client of the InfoStats2 API has requested a greater accuracy, that accuracy will be used instead.
 @param accuracy The accuracy to be requested for location data updates.<br/><br/>Available values:<br/>1 - Satellite navigation quality (GPS and additional sensors)<br/>2 - Satellite navigation quality (GPS only)<br/>3 - Within 10 meters of the user<br/>4 - Within 100 meters<br/>5 - Within 1 kilometer<br/>6 - Within 3 kilometers
 @param requester A unique identifier used to identify your code as requesting a particular acuracy. It is recommended to use reverse DNS notation, such as "com.foo.bar".
 */
+(void)setLocationUpdateAccuracy:(int)accuracy forRequester:(NSString*)requester;

/** Removes your code as requesting a particular acuracy, as detailed in <i>setLocationUpdateAccuracy:forRequester:</i>. This must be called once your code is unloaded, else location data will continue to update at the accuracy requested; if greater in accuracy than to within 100 meters, this will result in increased battery drainage.
 @param requester A unique identifier used to identify your code as requesting a particular interval. It is recommended to use reverse DNS notation, such as "com.foo.bar".
 */
+(void)removeRequesterForLocationAccuracy:(NSString*)requester;

/** Checks if the user has enabled Location Services in Settings.
 */
+(BOOL)isLocationServicesEnabled;

/** @name Data retrieval
 */

/** The latitude of the user's current location
 */
+(double)currentLatitude;

/** The longitude of the user's current location
 */
+(double)currentLongitude;

/** The city the user's current location is within.
 */
+(NSString*)cityForCurrentLocation;

/** The neighbourhood the user's current location is within. This may return null; at the time of writing, it is unsure whether this only works in the United States.
 */
+(NSString*)neighbourhoodForCurrentLocation;

/** The state the user's current location is within. Note: not to be confused with county.
 */
+(NSString*)stateForCurrentLocation;

/** The county the user's current location is within.
 */
+(NSString*)countyForCurrentLocation;

/** The country the user's current location is within.
 */
+(NSString*)countryForCurrentLocation;

/** The ISO Country Code for the country the user's current location is within.
 */
+(NSString*)ISOCountryCodeForCurrentLocation;

/** The post code for where the user's current location is located. When requesting a location update interval of 1 kilometer, this will not be accurate.
 */
+(NSString*)postCodeForCurrentLocation;

/** The street name for where the user's current location is located. When requesting a location update interval of 1 kilometer, this will not be accurate.
 */
+(NSString*)streetForCurrentLocation;

/** The house number for where the user's current location is located. When requesting a location update interval of 1 kilometer, this will not be accurate.
 */
+(NSString*)houseNumberForCurrentLocation;

@end
