//
//  IS2WeatherProvider.h
//  InfoStats2
//
//  Created by Matt Clarke on 02/06/2015.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface IS2WeatherProvider : NSObject <CLLocationManagerDelegate>

@property (nonatomic, copy) id callbackBlock;
@property (nonatomic) BOOL setup;
@property (nonatomic, readwrite) BOOL isUpdating;

+(instancetype)sharedInstance;

-(void)updateWeatherWithCallback:(void (^)(void))callbackBlock;
-(int)currentTemperature;
-(int)currentCondition;
-(NSString*)currentConditionAsString;
-(int)highForCurrentDay;
-(int)lowForCurrentDay;
-(int)currentWindSpeed;
-(NSString*)currentLocation;

@end
