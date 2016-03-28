//
//  IS2Location.m
//  InfoStats2
//
//  Created by Matt Clarke on 23/07/2015.
//
//

#import "IS2Location.h"
#import <CoreLocation/CoreLocation.h>
#import <notify.h>
#import "IS2WorkaroundDictionary.h"
#import "IS2Telephony.h"
#include <sys/time.h>

@interface CPDistributedMessagingCenter : NSObject
+(CPDistributedMessagingCenter*)centerNamed:(NSString*)serverName;
-(BOOL)sendMessageName:(NSString*)name userInfo:(NSDictionary*)info;
-(void)runServerOnCurrentThread;
-(void)stopServer;
-(void)registerForMessageName:(NSString*)messageName target:(id)target selector:(SEL)selector;
@end

void rocketbootstrap_distributedmessagingcenter_apply(CPDistributedMessagingCenter *messaging_center);

static CLLocation *location;
static CPDistributedMessagingCenter *center;
static int token;
static int firstUpdate = 0;
static IS2WorkaroundDictionary *locationUpdateBlockQueue;
static NSMutableDictionary *requesters;
static NSString *name; // eg. Apple Inc.
static NSString *thoroughfare; // street address, eg. 1 Infinite Loop
static NSString *subThoroughfare; // eg. 1
static NSString *locality; // city, eg. Cupertino
static NSString *subLocality; // neighborhood, common name, eg. Mission District
static NSString *administrativeArea; // state, eg. CA
static NSString *subAdministrativeArea; // county, eg. Santa Clara
static NSString *postalCode; // zip code, eg. 95014
static NSString *ISOcountryCode; // eg. US
static NSString *country; // eg. United States
static NSString *inlandWater; // eg. Lake Tahoe
static NSString *ocean; // eg. Pacific Ocean
static NSArray *areasOfInterest; // eg. Golden Gate Park

static time_t lastUpdateTime;

@implementation IS2Location

#pragma mark Private methods

+(void)setupAfterTweakLoaded {
    // Setup location.
    location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    center = [CPDistributedMessagingCenter centerNamed:@"com.matchstic.infostats2.location"];
    rocketbootstrap_distributedmessagingcenter_apply(center);
    [center runServerOnCurrentThread];
    [center registerForMessageName:@"locationData" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
    
    if (!requesters) {
        requesters = [NSMutableDictionary dictionary];
        
        NSMutableArray *manual = [NSMutableArray array];
        [requesters setObject:manual forKey:@"kManualUpdate"];
        
        NSMutableArray *turnbyturn = [NSMutableArray array];
        [requesters setObject:turnbyturn forKey:@"kTurnByTurn"];
        
        NSMutableArray *meters = [NSMutableArray array];
        [requesters setObject:meters forKey:@"k100Meters"];
        
        NSMutableArray *kilometer = [NSMutableArray array];
        [requesters setObject:kilometer forKey:@"k1Kilometer"];
    }
    
    // Request update to location data.
    static int first = 0;
    
    if (!first) {
        notify_register_check("com.matchstic.infostats2/requestLocationIntervalUpdate", &token);
        first = 1;
    }
    
    [self requestUpdateToLocationData];
    
    lastUpdateTime = time(NULL);
}

+(NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo {
    // Process userinfo (simple dictionary) and return a dictionary (or nil)
    double lat = [[userinfo objectForKey:@"latitude"] doubleValue];
    double longi = [[userinfo objectForKey:@"longitude"] doubleValue];
    
    location = [[CLLocation alloc] initWithLatitude:lat longitude:longi];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       // Correctly implement rate limiting.
                       
                       time_t currentTime = time(NULL);
                       
                       // If less than a minute has passed, don't update geocoder.
                       if (difftime(currentTime, lastUpdateTime) >= 60 || firstUpdate == 0) {
                           lastUpdateTime = currentTime;
                           firstUpdate = 1;
                           NSLog(@"[InfoStats2 | Location] :: Updating strings for new location data");
                       
                           if (error){
                               NSLog(@"[InfoStats2 | Location] :: Geocode failed with error: %@", error);
                           } else {
                               // Update names of things.
                               CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       
                               ISOcountryCode = placemark.ISOcountryCode;
                               country = placemark.country;
                               postalCode = placemark.postalCode;
                               administrativeArea = placemark.administrativeArea;
                               subAdministrativeArea = placemark.subAdministrativeArea;
                               locality = placemark.locality;
                               subLocality = placemark.subLocality;
                               subThoroughfare = placemark.subThoroughfare;
                               thoroughfare = placemark.thoroughfare;
                           
                               // Tell callbacks we have new data!
                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                   // Let all our callbacks know we've got new data available.
                                   for (void (^block)() in [locationUpdateBlockQueue allValues]) {
                                       @try {
                                           block();
                                       } @catch (NSException *e) {
                                           NSLog(@"[InfoStats2 | Location] :: Failed to update callback, with exception: %@", e);
                                       } @catch (...) {
                                           NSLog(@"[InfoStats2 | Location] :: Failed to update callback, with unknown exception");
                                       }
                                   }
                               });
                           }
                       } else {
                           // Just throw old data back at the requesters.
                           dispatch_async(dispatch_get_main_queue(), ^(void){
                               // Let all our callbacks know we've got new data available.
                               for (void (^block)() in [locationUpdateBlockQueue allValues]) {
                                   @try {
                                       block();
                                   } @catch (NSException *e) {
                                       NSLog(@"[InfoStats2 | Location] :: Failed to update callback, with exception: %@", e);
                                   } @catch (...) {
                                       NSLog(@"[InfoStats2 | Location] :: Failed to update callback, with unknown exception");
                                   }
                               }
                           });
                       }
    }];
    
    return nil;
}

#pragma mark Public methods

+(void)registerForLocationNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock {
    if (!locationUpdateBlockQueue) {
        locationUpdateBlockQueue = [IS2WorkaroundDictionary dictionary];
    }
    
    if (callbackBlock && identifier) {
        [locationUpdateBlockQueue addObject:callbackBlock forKey:identifier];
    }
}

+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier {
    [locationUpdateBlockQueue removeObjectForKey:identifier];
}

+(void)requestUpdateToLocationData {
    notify_set_state(token, 7);
    notify_post("com.matchstic.infostats2/requestLocationIntervalUpdate");
}

+(NSMutableArray*)arrayForRequester:(NSString*)requester {
    NSMutableArray *array;
    
    for (NSMutableArray *arr in [requesters allValues]) {
        if ([arr containsObject:requester]) {
            array = arr;
            break;
        }
    }
    
    return array;
}

+(void)setLocationUpdateDistanceInterval:(int)interval forRequester:(NSString*)requester {
    // Add to requesters, and change update interval if appropriate
    NSString *key = @"";
    switch (interval) {
        case kManualUpdate:
            key = @"kManualUpdate";
            break;
        case kTurnByTurn:
            key = @"kTurnByTurn";
            break;
        case k100Meters:
            key = @"k100Meters";
            break;
        case k1Kilometer:
            key = @"k1Kilometer";
            break;
        default:
            break;
    }
    
    // if requester is already present, remove it from it's existing thing.
    if ([self arrayForRequester:requester]) {
        [self removeRequesterForLocationDistanceInterval:requester];
    }
    
    NSMutableArray *requests = [requesters objectForKey:key];
    [requests addObject:requester];
    [requesters setObject:requests forKey:key];
    
    // Ask which requester is currently in vogue.
    IS2LocationUpdateInterval currentRequester = [self currentlyMostAccurateRequester];
    
    NSLog(@"[Infostats2 | Location] :: Requesting interval update to %lu", (unsigned long)currentRequester);
    
    uint64_t value = (uint64_t)currentRequester;
    
    notify_set_state(token, value);
    notify_post("com.matchstic.infostats2/requestLocationIntervalUpdate");
}

+(IS2LocationUpdateInterval)currentlyMostAccurateRequester {
    // TurnByTurn
    if ([[requesters objectForKey:@"kTurnByTurn"] count] > 0) {
        return kTurnByTurn;
    }
    
    // 100 Meters
    if ([[requesters objectForKey:@"k100Meters"] count] > 0) {
        return k100Meters;
    }
    
    // 1 Kilometer
    if ([[requesters objectForKey:@"k1Kilometer"] count] > 0) {
        return k1Kilometer;
    }
    
    // Otherwise, manual only!
    return kManualUpdate;
}

+(void)removeRequesterForLocationDistanceInterval:(NSString*)requester {
    // Remove from requesters, and change update interval if appropriate
    NSMutableArray *currentArray = [self arrayForRequester:requester];
    
    // Get the key for this array!
    NSString *key = @"";
    for (NSString *key2 in [requesters allKeys]) {
        NSMutableArray *arr = [requesters objectForKey:key];
        
        if ([arr containsObject:requester]) {
            key = key2;
            break;
        }
    }
    
    [currentArray removeObject:requester];
    
    [requesters setObject:currentArray forKey:key];
    
    // Ask which requester is currently in vogue.
    IS2LocationUpdateInterval currentRequester = [self currentlyMostAccurateRequester];
    
    uint64_t value = (uint64_t)currentRequester;
    
    notify_set_state(token, value);
    notify_post("com.matchstic.infostats2/requestLocationIntervalUpdate");
}

+(BOOL)isLocationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

+(double)currentLatitude {
    return location.coordinate.latitude;
}

+(double)currentLongitude {
    return location.coordinate.longitude;
}

+(NSString*)cityForCurrentLocation {
    return locality;
}

+(NSString*)neighbourhoodForCurrentLocation {
    return subLocality;
}

+(NSString*)stateForCurrentLocation {
    return administrativeArea;
}

+(NSString*)countyForCurrentLocation {
    return subAdministrativeArea;
}

+(NSString*)countryForCurrentLocation {
    return country;
}

+(NSString*)ISOCountryCodeForCurrentLocation {
    return ISOcountryCode;
}

+(NSString*)postCodeForCurrentLocation {
    return postalCode;
}

+(NSString*)streetForCurrentLocation {
    return thoroughfare;
}

+(NSString*)houseNumberForCurrentLocation {
    return subThoroughfare;
}

@end
