//
//  IS2LocationManager.h
//  
//
//  Created by Matt Clarke on 06/03/2016.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum : NSUInteger {
    kManualUpdate,
    kTurnByTurn,
    k100Meters,
    k1Kilometer
} IS2LocationUpdateInterval;

@interface IS2LocationManager : NSObject <CLLocationManagerDelegate> {
    NSMutableArray *_locationCallbacks;
    int authorisationStatus;
    IS2LocationUpdateInterval _interval;
}

@property (nonatomic, strong) CLLocationManager *locationManager;

-(void)setLocationUpdateInterval:(IS2LocationUpdateInterval)interval;
-(void)registerNewCallbackForLocationData:(void(^)(CLLocation*))callback;
-(int)currentAuthorisationStatus;

@end
