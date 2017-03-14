//
//  IS2Pedometer.m
//  
//
//  Created by Matt Clarke on 02/06/2016.
//
//

#import "IS2Pedometer.h"
#import "IS2Extensions.h"
#import "IS2WorkaroundDictionary.h"
#import <CoreMotion/CMPedometer.h>

static CMPedometer *pedometer;
static CMPedometerData *currentData;
static IS2WorkaroundDictionary *pedUpdateBlockQueue;
static NSTimer *timedUpdate;

NSDate *startOfTodayDate(void);

@interface CMPedometerData (iOS9)
@property(readonly, nonatomic) NSNumber *currentPace;
@property(readonly, nonatomic) NSNumber *currentCadence;
@end

@implementation IS2Pedometer

#pragma mark Private methods

NSDate *startOfTodayDate() {
    return [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
}

+(void)setupAfterSpringBoardLaunched {
    pedometer = [[CMPedometer alloc] init];
    timedUpdate = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(updatePedometerDataWithoutCallbacks:) userInfo:nil repeats:YES];
    
    // Grab data about today to seed everything nicely.
    [self updatePedometerDataWithoutCallbacks:nil];
}

+(void)setupAfterTweakLoaded {
    pedUpdateBlockQueue = [IS2WorkaroundDictionary dictionary];
}

+(void)significantTimeChange {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return;
    }
    
    if ([pedUpdateBlockQueue allKeys].count > 0) {
        [pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *data, NSError *error) {
            [self handleNewPedometerData:data withError:error];
        }];
    }
    
    // Grab data about today to seed everything nicely.
    [self updatePedometerDataWithoutCallbacks:nil];
}

+(void)handleNewPedometerData:(CMPedometerData*)data withError:(NSError*)error {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return;
    }
    
    if (!error) {
        currentData = data;
        
        // XXX: The usage of GCD and perform...MainThread is to avoid a deadlocking bug introduced in iOS 5, which
        // affects UIWebView.
        //
        // More info: http://stackoverflow.com/questions/19531701/deadlock-with-gcd-and-webview
        
        // Let callbacks know we have new data!
        for (void (^block)() in [pedUpdateBlockQueue allValues]) {
            @try {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[IS2Private sharedInstance] performSelectorOnMainThread:@selector(performBlockOnMainThread:) withObject:block waitUntilDone:NO];
                });
            } @catch (NSException *e) {
                NSLog(@"[InfoStats2 | Pedometer] :: Failed to update callback, with exception: %@", e);
            } @catch (...) {
                NSLog(@"[InfoStats2 | Pedometer] :: Failed to update callback, with unknown exception");
            }
        }
    } else {
        NSLog(@"[InfoStats2 | Pedometer] :: Failed to update steps data: %@", error);
    }
}

// Called on a timer to have semi-recent data sticking around.
+(void)updatePedometerDataWithoutCallbacks:(id)sender {
    [pedometer queryPedometerDataFromDate:startOfTodayDate() toDate:[NSDate date] withHandler:^(CMPedometerData *data, NSError *error) {
        currentData = data;
    }];
}

#pragma mark Public methods

+(void)registerForPedometerNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return;
    }
    
    if (!pedUpdateBlockQueue) {
        pedUpdateBlockQueue = [IS2WorkaroundDictionary dictionary];
    }
    
    if (callbackBlock && identifier) {
        [pedUpdateBlockQueue addObject:[callbackBlock copy] forKey:identifier];
    }
    
    if ([pedUpdateBlockQueue allKeys].count == 1) {
        [pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *data, NSError *error) {
            [self handleNewPedometerData:data withError:error];
        }];
    }
}

+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return;
    }
    
    [pedUpdateBlockQueue removeObjectForKey:identifier];
    
    if ([pedUpdateBlockQueue allKeys].count == 0) {
        [pedometer stopPedometerUpdates];
    }
}

// Data access.

+(int)numberOfSteps {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return 0;
    }
    
    return [currentData.numberOfSteps intValue];
}

// May be nil if current device doesn't support this
+(CGFloat)distanceTravelled {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return 0;
    }
    
    NSNumber *num = currentData.distance;
    
    if (!num) num = [NSNumber numberWithInt:0];
    
    return [num floatValue];
}

+(CGFloat)userCurrentPace {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return 0.0;
    }
    
    return [currentData.currentPace floatValue];
}

+(CGFloat)userCurrentCadence {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return 0.0;
    }
    
    return [currentData.currentCadence floatValue];
}

+(int)floorsAscended {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return 0;
    }
    
    return [currentData.floorsAscended intValue];
}

+(int)floorsDescended {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return 0;
    }
    
    return [currentData.floorsDescended intValue];
}

// Past output (JSON, and object form)



@end
