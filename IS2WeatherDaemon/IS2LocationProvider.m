//
//  IS2LocationProvider.m
//  
//
//  Created by Matt Clarke on 07/03/2016.
//
//

#import "IS2LocationProvider.h"
#import <objc/runtime.h>

@interface CPDistributedMessagingCenter : NSObject
+(CPDistributedMessagingCenter*)centerNamed:(NSString*)serverName;
-(BOOL)sendMessageName:(NSString*)name userInfo:(NSDictionary*)info;
@end

void rocketbootstrap_distributedmessagingcenter_apply(CPDistributedMessagingCenter *messaging_center);

@implementation IS2LocationProvider

-(id)initWithLocationManager:(IS2LocationManager*)locationManager {
    self = [super init];
    
    if (self) {
        self.locationManager = locationManager;
        
        [self.locationManager registerNewCallbackForLocationData:^(CLLocation *location) {
            // Tell SpringBoard about new location.
            CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:@"com.matchstic.infostats2.location"];
            rocketbootstrap_distributedmessagingcenter_apply(c);
            
            NSMutableDictionary *locDict = [NSMutableDictionary dictionary];
            [locDict setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
            [locDict setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
            
            [c sendMessageName:@"locationData" userInfo:locDict]; //send an NSDictionary here to pass data
        }];
    }
    
    return self;
}

-(void)setLocationUpdateInterval:(uint64_t)interval {
    [self.locationManager setLocationUpdateInterval:(int)interval];
}

-(void)requestLocationUpdate {
    [self.locationManager.locationManager startUpdatingLocation];
}

@end
