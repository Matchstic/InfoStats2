//
//  IS2WeatherProvider.h
//  InfoStats2
//
//  Created by Matt Clarke on 02/06/2015.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface IS2WeatherUpdater : NSObject <CLLocationManagerDelegate>

//@property (nonatomic) BOOL setup;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end
