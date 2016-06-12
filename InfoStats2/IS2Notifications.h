//
//  IS2Notifications.h
//  InfoStats2
//
//  Created by Matt Clarke on 23/07/2015.
//
//

#import <Foundation/Foundation.h>

/** IS2Notifications provides access to notifications present on the user's device. All data returned is pulled from the Notification Centre (NC), and so can persist over reboots.
 */
@interface IS2Notifications : NSObject

/** @name Setup
 */

/** Sets a block to be called whenever a new notification arrives, or an old notification is removed. The identifier must be unique string; it is recommended to use reverse DNS notation, such as "com.foo.bar".
@param identifier The identifier associated with your callback
@param callbackBlock The block to call once data changes
*/
+(void)registerForBulletinNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock;

/** The inverse of registering for notifications. This must be called when your code is unloaded, else your device will become as unstable as Windows Vista.
 @param identifier The identifier associated with your callback
 */
+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier;

/** @name Data retrieval
 */

/** Provides the current count of notifications for the specified application identifier. This will be the number of notifications in the Notification Centre or the application's badge number, whichever is higher.
 @param bundleIdentifier The bundle identifier of the application specified
 @return The count of notifications
 */
+(int)notificationCountForApplication:(NSString*)bundleIdentifier;

/** Provides the count of notifications on the lockscreen for the given app. This is calculated by counting how many notifications came in for the specified application whilst the device has been locked. 0 will always be returned whilst the device is unlocked.
 @param bundleIdentifier The bundle identifier of the application specified
 @return The count of notifications displayed on the lockscreen.
 */
+(int)lockscreenNotificationCountForApplication:(NSString*)bundleIdentifier;

/** Provides the total count of notifications over all applications.
 @param onLockscreenOnly If true, this will only return the count of notifications displayed on the lockscreen. If the device is unlocked, this will always be 0.
 @return The total count of notifications
 */
+(int)totalNotificationCountOnLockScreenOnly:(BOOL)onLockscreenOnly;

/** Gives an array of <code>BBBulletin</code> objects representing the data currently available in the Notification Centre. If the application specified is prevented from displaying items in the NC through Settings, then this will return an emtpy array.
 @param bundleIdentifier The bundle identifier of the application specified
 @return An array of <code>BBBulletin</code> objects.
 */
+(NSArray*)notificationsForApplication:(NSString*)bundleIdentifier;

/** Gives a JSON representation of data currently available in the Notification Centre. Those using the API via JAvaScript should use this method to obtain a list of notifications. If the application specified is prevented from displaying items in the NC through Settings, then this will return an emtpy array.
 @param bundleIdentifier The bundle identifier of the application specified
 @return A JSON representation of notifications, in the form:<code><br/>
 [<br/>
 &emsp;{<br/>
 &emsp;&emsp;"title": "Example notification",<br/>
 &emsp;&emsp;"message": "Example message",<br/>
 &emsp;&emsp;"bundleIdentifier": "com.foo.example", (Identifier of application for bulletin)<br/>
 &emsp;&emsp;"timeFired": 1451528264000 (Timestamp in milliseconds)<br/>
 &emsp;},<br/>
 &emsp;{<br/>
 &emsp;&emsp;...<br/>
 &emsp;}<br/>
 ]<br/></code>
 */
+(NSString*)notificationsJSONForApplication:(NSString*)bundleIdentifier;

/** @name Functions
 */

/** Displays a new notification to the user, and will <b>not</b> be stored in the Notification Centre. The default sound for alerts will be used if the device is un-muted, or the default vibration pattern will be used if available. On the lockscreen, this notification will be seen as a new cell in the notification list, or when unlocked, a banner will be shown to the user.
 @param title The title of the notification
 @param message A short message to display to the user
 @param bundleIdentifier A bundle identifier associated with an application on the user's device. This controls the icon of the notification, and if not set, will default to the identifier for the Settings application.
 */
+(void)publishBulletinWithTitle:(NSString*)title message:(NSString*)message andBundleIdentifier:(NSString*)bundleIdentifier;

@end
