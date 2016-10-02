//
//  IS2DaemonListener.h
//  
//
//  Created by Matt Clarke on 06/03/2016.
//
//

#import <Foundation/Foundation.h>
#import "IS2WeatherProvider.h"
#import "IS2LocationProvider.h"

@interface IS2DaemonListener : NSObject

@property (nonatomic, strong) IS2WeatherUpdater *weatherProvider;
@property (nonatomic, strong) IS2LocationProvider *locationProvider;

-(void)loadFromSavedState;

@end
