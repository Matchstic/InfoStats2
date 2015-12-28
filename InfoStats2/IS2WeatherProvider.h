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

@property (nonatomic) BOOL setup;
@property(strong, nonatomic) NSBundle *weatherFrameworkBundle;
@property (nonatomic, readwrite) BOOL isUpdating;

+(instancetype)sharedInstance;

-(void)updateWeatherWithCallback:(void (^)(void))callbackBlock;
-(int)currentTemperature;
-(int)currentCondition;
-(NSString*)currentConditionAsString;
-(int)highForCurrentDay;
-(int)lowForCurrentDay;
-(int)currentWindSpeed;

//-(int)currentDewPoint;
//-(int)currentHumidity;
//-(int)currentWindChill;
//-(int)currentVisibilityPercent;
//-(int)currentChanceOfRain;
//-(int)currentlyFeelsLike;
//-(unsigned int)sunsetUNIXTime;
//-(unsigned int)sunriseUNIXTime;
//-(NSDate*)lastUpdateTime;

-(NSString*)translatedWindSpeedUnits;

-(NSString*)currentLocation;
-(NSArray*)hourlyForecastsForCurrentLocation;
-(NSArray*)dayForecastsForCurrentLocation;

-(BOOL)isCelsius;

@end
