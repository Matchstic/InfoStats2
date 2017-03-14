//
//  IS2Telephony.h
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//  Tested iOS 6.1 -> iOS 10.2.
//  No known issues.

#import <Foundation/Foundation.h>

/** IS2Telephony is used to access data for both baseband information, and WiFi data. For functions relating to modifying the state of telephony related items, please see IS2System, as that contains the functions for toggling various system settings.
 */

@interface IS2Telephony : NSObject

/** @name Data Retrieval */

/** Gives the amount of signal bars the user sees in the status bar UI. As such, it is not 100% accurate. This will be 0 for iPod or WiFi-only iPad.
 @return The currrent amount of signal bars
 */
+(int)phoneSignalBars;

/** Gives the current signal quality in RSSI.
 @return The currrent GSM/CDMA RSSI
 */
+(int)phoneSignalRSSI;

/** Gives the carrier name that the user's device is currently on. May be NULL or "" for an iPod or iPad.
 @return User's GSM/CDMA carrier
 */
+(NSString*)phoneCarrier;

/** Gives a boolean as to whether WiFi hardware is powered on or not.
 @return Current WiFi powered state
 */
+(BOOL)wifiEnabled;

/** Gives the amount of WiFi bars that are currently displayed in the status bar. This is not as fine-grained as the WiFi RSSI.
 @return The currrent amount of WiFi bars
 */
+(int)wifiSignalBars;

/** Gives the current WiFi signal quality in RSSI
 @return The currrent WiFi RSSI
 */
//+(int)wifiSignalRSSI;

/** Gives the WiFi SSID that the user's device is currently connected to. May be NULL or "" if WiFi is not enabled, or is not connected.
 @return Current WiFI SSID
 */
+(NSString*)wifiName;

/** Gives a boolean as to whether Airplane Mode is currently enabled.
 @return Airplane Mode state
 */
+(BOOL)airplaneModeEnabled;

/** Gives a boolean as to whether a data connection is available via WiFi.
 @return If a data connection is available over WiFi
 */
+(BOOL)dataConnectionAvailableViaWiFi;

/** Gives a boolean as to whether a data connection is available via WiFi or cellular data.
 @return If a data connection is available over WiFi or cellular data
 */
+(BOOL)dataConnectionAvailable;

@end
