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
+(void)registerForNowPlayingNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock;

/** The inverse of registering for notifications. This must be called when your code is unloaded, else your device may play Disney's Let It Go at the worst possible moments.
 @param identifier The identifier associated with your callback
 */
+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier;

/** @name Requesting data
 */

/** Requests an immediate update to location data. Please note that this will not notify your callback for location changes if Location Services is disabled.
 */
+(void)requestUpdateToLocationData;

/** Sets the distance interval the user must travel before a location data update is performed. By default, this is set to "manual updating", whereupon location data is only updated after calling <i>requestUpdateToLocationData</i>.<br/><br/>If another client of the InfoStats2 API has requested a more accurate distance interval, that more accurate interval will be used instead.
 
 @param interval The interval to be requested for location data updates.<br/><br/>Available values:<br/>1 - Update every 10 meters moved<br/>2 - Update every 100 meters<br/>3 - Update every 1 kilometer
 @param requester A unique identifier used to identify your code as requesting a particular interval. It is recommended to use reverse DNS notation, such as "com.foo.bar".
 */
+(void)setLocationUpdateDistanceInterval:(int)interval forRequester:(NSString*)requester;

/** Removes your code as requesting a particular update interval, as detailed in <i>setLocationUpdateDistanceInterval:forRequester:</i>. This must be called once your code is unloaded, else location data will continue to be updated, thus draining battery.
 @param requester A unique identifier used to identify your code as requesting a particular interval. It is recommended to use reverse DNS notation, such as "com.foo.bar".
 */
+(void)removeRequesterForLocationDistanceInterval:(NSString*)requester;

/** 
 */
+(BOOL)isLocationServicesEnabled;

+(double)currentLatitude;
+(double)currentLongitude;
+(NSString*)cityForCurrentLocation;
+(NSString*)neighbourhoodForCurrentLocation;
+(NSString*)stateForCurrentLocation;
+(NSString*)countyForCurrentLocation;
+(NSString*)countryForCurrentLocation;
+(NSString*)ISOCountryCodeForCurrentLocation;
+(NSString*)postCodeForCurrentLocation;
+(NSString*)streetForCurrentLocation;
+(NSString*)houseNumberForCurrentLocation;

@end
