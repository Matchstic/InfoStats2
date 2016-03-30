//
//  IS2LocationManager.m
//  
//
//  Created by Matt Clarke on 06/03/2016.
//
//

#import "IS2LocationManager.h"

@implementation IS2LocationManager

-(id)init {
    self = [super init];
    
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        
        // We'll default to manual updating.
        _interval = kManualUpdate;
        
        //[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
        //[self.locationManager setDistanceFilter:kCLDistanceFilterNone];
        [self setLocationUpdateAccuracy:4];
        [self setLocationUpdateInterval:_interval];
        [self.locationManager setDelegate:self];
        [self.locationManager setActivityType:CLActivityTypeAutomotiveNavigation]; // Allows use of GPS
        
        authorisationStatus = kCLAuthorizationStatusNotDetermined;
    }
    
    return self;
}

-(void)setLocationUpdateInterval:(IS2LocationUpdateInterval)interval {
    switch (interval) {
        case kTurnByTurn:
            NSLog(@"[InfoStats2d | Location] :: Setting interval to 10 meters");
            [self.locationManager setDistanceFilter:10.0];
            [self.locationManager startUpdatingLocation];
            break;
        case k100Meters:
            //[self.locationManager stopUpdatingLocation];
            NSLog(@"[InfoStats2d | Location] :: Setting interval to 100 meters");
            [self.locationManager setDistanceFilter:100.0];
            [self.locationManager startUpdatingLocation];
            break;
        case k1Kilometer:
            //[self.locationManager stopUpdatingLocation];
            NSLog(@"[InfoStats2d | Location] :: Setting interval to 1 km");
            [self.locationManager setDistanceFilter:1000.0];
            [self.locationManager startUpdatingLocation];
            break;
        case kManualUpdate:
            NSLog(@"[InfoStats2d | Location] :: Setting interval to manual mode");
            [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
            [self.locationManager stopUpdatingLocation];
            break;
            
        default:
            break;
    }
    
    _interval = interval;
}

-(void)setLocationUpdateAccuracy:(int)accuracy {
    switch (accuracy) {
        case 1:
            NSLog(@"[InfoStats2d | Location] :: Setting accuracy to BestForNavigation");
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
            break;
        case 2:
            NSLog(@"[InfoStats2d | Location] :: Setting accuracy to Best");
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
            break;
        case 3:
            NSLog(@"[InfoStats2d | Location] :: Setting accuracy to within 10 meters");
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
            break;
        case 4:
            NSLog(@"[InfoStats2d | Location] :: Setting accuracy to within 100 meters");
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
            break;
        case 5:
            NSLog(@"[InfoStats2d | Location] :: Setting accuracy to within 1 kilometer");
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
            break;
        case 6:
            NSLog(@"[InfoStats2d | Location] :: Setting accuracy to within 3 kilometers");
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
            break;
            
        default:
            break;
    }
    
    if (_interval != kManualUpdate) {
        [self.locationManager startUpdatingLocation];
    }
    
    _accuracy = accuracy;
}

-(void)registerNewCallbackForLocationData:(void(^)(CLLocation*))callback {
    if (!_locationCallbacks) {
        _locationCallbacks = [NSMutableArray array];
    }
    
    [_locationCallbacks addObject:callback];
}

-(void)registerNewCallbackForAuth:(void(^)(int))callback {
    if (!_authCallbacks) {
        _authCallbacks = [NSMutableArray array];
    }
    
    [_authCallbacks addObject:callback];
}

-(int)currentAuthorisationStatus {
    return authorisationStatus;
}

- (void)locationManager:(id)arg1 didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"[InfoStats2d | Location Manager] :: Auth state changed to %d.", status);
    
    int oldStatus = authorisationStatus;
    authorisationStatus = status;
    
    for (void(^callback)(int) in _authCallbacks) {
        callback(authorisationStatus);
    }
    
    if (oldStatus == kCLAuthorizationStatusAuthorized && oldStatus != status) {
        [self.locationManager stopUpdatingLocation];
    } else if (_interval != kManualUpdate && authorisationStatus == kCLAuthorizationStatusAuthorized) {
        [self.locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"[InfoStats2d | Location Manager] :: Failed to update locations, %@", error.localizedDescription);
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"[InfoStats2d | Location Manager] :: Updating locations has been paused by the system");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"[InfoStats2d | Location Manager] :: Updating locations has been resumed by the system");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"[InfoStats2d | Location Manager] :: Did update locations, with array count %d.", (int)locations.count);
    
    if (_locationStoppedTimer) {
        [_locationStoppedTimer invalidate];
        _locationStoppedTimer = nil;
    }
    
    // Locations updated! We can now ask for an update to weather with the new locations.
    CLLocation *mostRecentLocation = [[locations lastObject] copy];

    // Give callbacks our new location.
    for (void(^callback)(CLLocation*) in _locationCallbacks) {
        callback(mostRecentLocation);
    }
    
    if (_interval == kManualUpdate) {
        [self.locationManager stopUpdatingLocation];
    } else {
        _locationStoppedTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(_locationStoppedTimer:) userInfo:nil repeats:NO];
    }
}

-(void)_locationStoppedTimer:(id)sender {
    [_locationStoppedTimer invalidate];
    _locationStoppedTimer = nil;
    
    // Get one last location.
    
}

@end
