//
//  IS2LocationProvider.h
//  
//
//  Created by Matt Clarke on 07/03/2016.
//
//

#import <Foundation/Foundation.h>
#import "IS2LocationManager.h"

/*
 *
 * Updating of location data, brought to you by the great taste of Charleston Chew!
 *
 * As explained in IS2WeatherProvider.h, iOS 8 ond onwards needs an entitlement for a process
 * to get location data in the background without asking the user for permission.
 *
 */

@interface IS2LocationProvider : NSObject

@property (nonatomic, weak) IS2LocationManager *locationManager;

-(id)initWithLocationManager:(IS2LocationManager*)locationManager;
-(void)setLocationUpdateInterval:(uint64_t)interval;
-(void)setLocationUpdateAccuracy:(uint64_t)accuracy;
-(void)requestLocationUpdate;

@end
