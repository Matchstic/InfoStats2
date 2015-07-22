//
//  IS2System.h
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import <Foundation/Foundation.h>

/** IS2System is used to access various system related data and functions, such as the RAM and battery data found in the original InfoStats, and functions such as launching applications.
 */

@interface IS2System : NSObject


/** @name Battery data 
 */

/** Gives the current percentage of the battery remaining. This value is equal to that shown in the status bar.
@return The currrent battery remaining percentage
*/
+(int)batteryPercent;

/** Gives the current state of the battery as a string, which is pre-translated for you.
 @return The currrent battery state
 */
+(NSString*)batteryState;

/** Gives the current state of the battery as an integer, which may be used if you wish to supply your own strings for each state.
 @return The currrent battery state as an integer
 */
+(int)batteryStateAsInteger;



/** @name RAM data
 */

/** Gives the current amount of free RAM in megabytes (MB). This is calculated by adding the free RAM to the inactive RAM, since it appears iOS also treats inactive as free.
 @return The currrent amount of free RAM
 */
+(int)ramFree;

/** Gives the current amount of used RAM in megabytes (MB).
 @return The currrent amount of used RAM
 */
+(int)ramUsed;

/** Gives the amount of RAM available on the device in megabytes (MB).
 @return The amount of available RAM
 */
+(int)ramAvailable;



/** @name System functions 
 */

/** Takes a screenshot of the current screen, and saves it in the user's photos.
 */
+(void)takeScreenshot;

/** Locks the device. Doesn't need much more explanation really.
 */
+(void)lockDevice;

/** Opens the app switcher.
 */
+(void)openSwitcher;

/** Launches a given application to the foreground.
 @param bundleIdentifier The bundle identifier of the application to launch
 */
+(void)openApplication:(NSString*)bundleIdentifier;

/** @name System toggles 
 */

@end
