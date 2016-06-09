//
//  IS2Pedometer.h
//  
//
//  Created by Matt Clarke on 02/06/2016.
//
//

#import <Foundation/Foundation.h>

/** IS2Pedometer provides access to the pedometer data found in the Helath app bundled with iOS. Please note, due to the underlying APIs used here, this class is iOS 8+ only.
 */

@interface IS2Pedometer : NSObject

+(void)registerForPedometerNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock;
+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier;
+(NSNumber*)numberOfSteps;
+(NSNumber*)distanceTravelled;
+(NSNumber*)userCurrentPace; // iOS 9+
+(NSNumber*)userCurrentCadence; // iOS 9+
+(NSNumber*)floorsAscended;
+(NSNumber*)floorsDescended;

@end
