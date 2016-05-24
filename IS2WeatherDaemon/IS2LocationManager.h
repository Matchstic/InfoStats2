//
//  IS2LocationManager.h
//  
//
//  Created by Matt Clarke on 06/03/2016.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <time.h>

typedef enum : NSUInteger {
    kManualUpdate,
    kTurnByTurn,
    k100Meters,
    k500Meters,
    k1Kilometer
} IS2LocationUpdateInterval;

@interface IS2LocationManager : NSObject <CLLocationManagerDelegate> {
    NSMutableArray *_locationCallbacks;
    NSMutableArray *_authCallbacks;
    int authorisationStatus;
    IS2LocationUpdateInterval _interval;
    int _accuracy;
    NSTimer *_locationStoppedTimer;
    BOOL _isUpdatingPaused;
    int _currentPauseInterval;
    CLLocation *_lastLocation;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, readwrite) BOOL isDisplayOff;

-(void)setLocationUpdateInterval:(IS2LocationUpdateInterval)interval;
-(void)setLocationUpdateAccuracy:(int)accuracy;
-(void)registerNewCallbackForLocationData:(void(^)(CLLocation*))callback;
-(void)registerNewCallbackForAuth:(void(^)(int))callback;
-(int)currentAuthorisationStatus;

@end
