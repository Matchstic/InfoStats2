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

/** @name Device Data */

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

/** Gives the current CPU usage in percent (across all available cores)
 @return Current CPU usage (combined for system processes and user processes)
 */
+(double)cpuUsage;

/** Gives the current free space left on the device. 
 @param format Adjusts the output of the function to be in bytes, kb, MB or GB:<br/>0 - Bytes<br/>1 - kb<br/>2 - MB<br/>3 - GB
 */
+(double)freeDiskSpaceInFormat:(int)format;

/** Gives the amount of space available on the device.
 @param format Adjusts the output of the function to be in bytes, kb, MB or GB:<br/>0 - Bytes<br/>1 - kb<br/>2 - MB<br/>3 - GB
 */
+(double)totalDiskSpaceInFormat:(int)format;

/** Gives the current upload speed of the user's network connection.
 @return Up speed in kb/s
 */
+(double)networkSpeedUp;

/** Gives the current download speed of the user's network connection.
 @return Down speed in kb/s
 */
+(double)networkSpeedDown;

/** Gives the current upload speed of the user's network connection, which is automatically formatted between b/s to GB/s dependant on the value.
 @return Up speed, auto formatted
 */
+(NSString*)networkSpeedUpAutoConverted;

/** Gives the current download speed of the user's network connection, which is automatically formatted between b/s to GB/s dependant on the value.
 @return Download speed, auto formatted
 */
+(NSString*)networkSpeedDownAutoConverted;

/** Gives the user-assigned name of the device.
 @return Device name as set by user (eg, "Matt's iPhone")
 */
+(NSString*)deviceName;

/** Gives the device type, eg iPhone, iPad or iPod
 @return Device type
 */
+(NSString*)deviceType;

/** Gives the exact model of the current device, eg iPhone7,2
 @return Device model
 */
+(NSString*)deviceModel;

/** Gives a more human-friendly version of +deviceModel. Eg, iPhone7,2 becomes iPhone 6.<br/><br/>Note that this function will need to be updated each time a new device is released by Apple. 
 @return Device model in a more understandable format
 */
+(NSString*)deviceModelHumanReadable;

/** Gives the height of the device's display in points. This does not change if the device is rotated.
 @return The height of the display
 */
+(int)deviceDisplayHeight;

/** Gives the width of the device's display in points. This does not change if the device is rotated.
 @return The width of the display
 */
+(int)deviceDisplayWidth;

/** Gives whether the user is using their device in 24hr time, or in 12hr time
 @return Whether device is in 24hr time or not
 */
+(BOOL)isDeviceIn24Time;

/** Gives whether the user has the passcode UI visible on their lockscreen at the time of calling.<br/><br/>Please note that this will return NO when the device:<br/>- Is unlocked<br/>- Has not got a passcode set
 @return Whether passocde UI is currently shown on the lockscreen
 */
+(BOOL)isLockscreenPasscodeVisible;

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

/** Opens the Siri interface.
 */
+(void)openSiri;

/** Relaunches SpringBoard immediately after calling.
 */
+(void)respring;

/** Reboots the device immediately after calling.
 */
+(void)reboot;

/** Vibrates the device (triggers an audible alert instead if vibration is not available) for 0.2 seconds. This respects the user setting "Vibrate on Silent" found under Sounds; no vibration will occur when this is turned off.
 */
+(void)vibrateDevice;

/** Vibrates the device (audible alert if vibration is unavailable) for a custom period of time. This respects the user setting "Vibrate on Silent" found under Sounds; no vibration will occur when this is turned off.
 @param timeLength Length of time in seconds to vibrate the device for
 */
+(void)vibrateDeviceForTimeLength:(CGFloat)timeLength;

/** @name Miscellaneous Settings
 */

/** Gives the current backlight level, which will be between 0.0 and 1.0.
 @return Current backlight level
 */
+(CGFloat)getBrightness;

/** Sets the current backlight level, and expects values between 0.0 and 1.0
 @param level The new backlight level
 */
+(void)setBrightness:(CGFloat)level;

/** Gives the current state of the Low Power mode.<br/><br/>This will return NO for versions of iOS less than iOS 9.
 @return Current Low Power mode state
 */
+(BOOL)getLowPowerMode;

/** Sets the current Low Power mode state.<br/><br/>This will do nothing for versions of iOS less than iOS 9.
 @param mode The new mode; YES for on, NO for off.
 */
+(void)setLowPowerMode:(BOOL)mode;

/** @name Application Icons
 */

/** Finds the application icon for a given bundle identifier.<br/><br/>Please note this function respects the user's current theme.
 @return Application icon for provided bundle identifier
 */
+(UIImage*)getApplicationIconForBundleIdentifier:(NSString*)bundleIdentifier;

/** Finds the application icon for a given bundle identifier, in the form of a base64 string for usage within a HTML <i>img</i> tag.<br/><br/>Please note this function respects the user's current theme.
 @return Application icon (in base64 format) for provided bundle identifier
 */
+(NSString*)getApplicationIconForBundleIdentifierBase64:(NSString*)bundleIdentifier;

/** @name Device Wallpaper
 */

/** Gives a snapshot of the user's current wallpaper. For Dynamic wallpapers, and tweaks that override the wallpaper, this function will return a still snapshot of what is displayed at the time of calling.
 @param variant The wallpaper variant to retrieve. Pass 0 for the lockscreen wallpaper, or 1 for the homescreen
 @return The wallpaper snapshot
 */
//+(UIImage*)getWallpaperForVariant:(int)variant;

/** Gives a snapshot of the user's current wallpaper, in the form of a base64 string for usage within a HTML <i>img</i> tag. For Dynamic wallpapers, and tweaks that override the wallpaper, this function will return a still snapshot of what is displayed at the time of calling.
 @param variant The wallpaper variant to retrieve. Pass 0 for the lockscreen wallpaper, or 1 for the homescreen
 @return The wallpaper snapshot
 */
//+(NSString*)getWallpaperForVariantBase64:(int)variant;


//+(void)setWallpaperWithImage:(UIImage*)img forMode:(int)mode;
//+(void)setWallpaperWithBase64Image:(NSString*)img forMode:(int)mode;

@end
