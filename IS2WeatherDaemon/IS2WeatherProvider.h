//
//  IS2WeatherProvider.h
//  InfoStats2
//
//  Created by Matt Clarke on 02/06/2015.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "IS2LocationManager.h"
#include <sys/time.h>

@interface IS2WeatherUpdater : NSObject {
    time_t _lastUpdateTime;
    time_t _currentUpdateTime;
}

//@property (nonatomic) BOOL setup;
@property (nonatomic, weak) IS2LocationManager *locationManager;
@property (nonatomic, strong) Reachability *reach;

-(void)updateWeather;
-(id)initWithLocationManager:(IS2LocationManager*)locationManager;

@end
