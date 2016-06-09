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
    if ([pedUpdateBlockQueue allKeys].count > 0) {
        [pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *data, NSError *error) {
            [self handleNewPedometerData:data withError:error];
        }];
    }
    
    // Grab data about today to seed everything nicely.
    [self updatePedometerDataWithoutCallbacks:nil];
}

+(void)handleNewPedometerData:(CMPedometerData*)data withError:(NSError*)error {
    if (!error) {
        currentData = data;
        
        // Let callbacks know we have new data!
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            for (void (^block)() in [pedUpdateBlockQueue allValues]) {
                    @try {
                        [[IS2Private sharedInstance] performSelectorOnMainThread:@selector(performBlockOnMainThread:) withObject:block waitUntilDone:NO];
                    } @catch (NSException *e) {
                        NSLog(@"[InfoStats2 | Pedometer] :: Failed to update callback, with exception: %@", e);
                    } @catch (...) {
                        NSLog(@"[InfoStats2 | Pedometer] :: Failed to update callback, with unknown exception");
                    }
            }
        });
    } else {
        NSLog(@"*** [InfoStats2 | Pedometer] :: Failed to update steps data: %@", error);
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
    if (!pedUpdateBlockQueue) {
        pedUpdateBlockQueue = [IS2WorkaroundDictionary dictionary];
    }
    
    if (callbackBlock && identifier) {
        [pedUpdateBlockQueue addObject:callbackBlock forKey:identifier];
    }
    
    if ([pedUpdateBlockQueue allKeys].count == 1) {
        [pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *data, NSError *error) {
            [self handleNewPedometerData:data withError:error];
        }];
    }
}

+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier {
    [pedUpdateBlockQueue removeObjectForKey:identifier];
    
    if ([pedUpdateBlockQueue allKeys].count == 0) {
        [pedometer stopPedometerUpdates];
    }
}

// Data access.

+(NSNumber*)numberOfSteps {
    return currentData.numberOfSteps;
}

// May be nil if current device doesn't support this
+(NSNumber*)distanceTravelled {
    NSNumber *num = currentData.distance;
    
    if (!num) num = [NSNumber numberWithInt:0];
    
    return num;
}

+(NSNumber*)userCurrentPace {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return [NSNumber numberWithInt:0];
    }
    
    return currentData.currentPace;
}

+(NSNumber*)userCurrentCadence {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return [NSNumber numberWithInt:0];
    }
    
    return currentData.currentCadence;
}

+(NSNumber*)floorsAscended {
    return currentData.floorsAscended;
}

+(NSNumber*)floorsDescended {
    return currentData.floorsDescended;
}

// Past output (JSON, and object form)



@end
