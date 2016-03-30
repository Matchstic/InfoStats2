//
//  IS2LocationProvider.h
//  
//
//  Created by Matt Clarke on 07/03/2016.
//
//

#import <Foundation/Foundation.h>
#import "IS2LocationManager.h"

@interface IS2LocationProvider : NSObject

@property (nonatomic, weak) IS2LocationManager *locationManager;

-(id)initWithLocationManager:(IS2LocationManager*)locationManager;
-(void)setLocationUpdateInterval:(uint64_t)interval;
-(void)setLocationUpdateAccuracy:(uint64_t)accuracy;
-(void)requestLocationUpdate;

@end
