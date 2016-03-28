//
//  IS2WeatherProvider.h
//  InfoStats2
//
//  Created by Matt Clarke on 02/06/2015.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#include <time.h>

@interface IS2WeatherProvider : NSObject <CLLocationManagerDelegate> {
    NSTimer *_updateTimoutTimer;
    time_t lastUpdateTime;
    time_t currentUpdateTime;
}

@property (nonatomic) BOOL setup;
@property(strong, nonatomic) NSBundle *weatherFrameworkBundle;
@property (nonatomic, readwrite) BOOL isUpdating;

+(instancetype)sharedInstance;
-(void)setupForTweakLoaded;

-(void)updateWeatherWithCallback:(void (^)(void))callbackBlock;
-(int)currentTemperature;
-(int)currentCondition;
-(NSString*)currentConditionAsString;
-(NSString*)naturalLanguageDescription;
-(int)highForCurrentDay;
-(int)lowForCurrentDay;
-(int)currentWindSpeed;

-(int)currentDewPoint;
-(int)currentHumidity;
-(int)currentWindChill;
-(BOOL)isWindSpeedMph;
-(int)currentVisibilityPercent;
-(int)currentChanceOfRain;
-(int)currentlyFeelsLike;
-(NSString*)sunsetTime;
-(NSString*)sunriseTime;
-(NSDate*)lastUpdateTime;

-(CGFloat)currentLatitude;
-(CGFloat)currentLongitude;
-(float)currentPressure;
-(int)windDirection;

-(NSString*)translatedWindSpeedUnits;

-(NSString*)currentLocation;
-(NSArray*)hourlyForecastsForCurrentLocation;
-(NSArray*)dayForecastsForCurrentLocation;
-(NSString*)dayForecastsForCurrentLocationJSON;
-(NSString*)hourlyForecastsForCurrentLocationJSON;

-(BOOL)isCelsius;

@end
