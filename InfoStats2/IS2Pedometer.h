//
//  IS2Pedometer.h
//  
//
//  Created by Matt Clarke on 02/06/2016.
//
//

#import <Foundation/Foundation.h>

/** IS2Pedometer provides access to the pedometer data found in the Health app bundled with iOS. Please note, due to the underlying APIs used here, this class is <b>iOS 9+ only</b>.<br/><br/><b>All values returned by this class are in relation to the current day.</b>
 */
@interface IS2Pedometer : NSObject

/** Sets a block to be called whenever the user's pedometer data changes. The identifier must be unique string; it is recommended to use reverse DNS notation, such as "com.foo.bar".
 @param identifier The identifier associated with your callback
 @param callbackBlock The block to call once data changes
 */
+(void)registerForPedometerNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock;

/** The inverse of registering for notifications. This must be called when your code is unloaded!
 @param identifier The identifier associated with your callback
 */
+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier;

/** @name Data retrieval
 */

/** The number of steps taken by the user.
 */
+(int)numberOfSteps;

/** The estimated distance (in meters) traveled by the user.<br/><br/>This value reflects the distance traveled while walking and running. The value in this property may be 0 if distance estimation is not supported on the current device.
 */
+(CGFloat)distanceTravelled;

/** The current pace of the user, measured in seconds per meter.<br/><br/>This value may be 0 for devices that do not support the gathering of pace data.
 */
+(CGFloat)userCurrentPace;

/** The rate at which steps are taken, measured in steps per second.<br/><br/>This value may be 0 for devices that do not support the gathering of cadence data.
 */
+(CGFloat)userCurrentCadence;

/** The approximate number of floors ascended by walking.<br/><br/>This value is 0 when floor counting is not supported on the current device.
 */
+(int)floorsAscended;

/** The approximate number of floors descended by walking.<br/><br/>This value is 0 when floor counting is not supported on the current device.
 */
+(int)floorsDescended;

@end
