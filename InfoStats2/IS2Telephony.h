//
//  IS2Telephony.h
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import <Foundation/Foundation.h>

/** IS2Telephony is used to access data for both baseband information, and WiFi data. For functions relating to modifying the state of telephony related items, please see IS2System, as that contains the functions for toggling various system settings.
 */

@interface IS2Telephony : NSObject

/** Sets a block to be called whenever music data changes. It is highly advisable to use this, as it will allow for your code to be automatically notified of any change in media data.
 @return The currrent amount of bars shown in the status bar
 */
+(int)phoneSignalBars;
+(int)phoneSignalRSSI;
+(NSString*)phoneCarrier;
+(BOOL)wifiEnabled;
+(int)wifiSignalBars;
+(int)wifiSignalRSSI;
+(NSString*)wifiName;
+(BOOL)airplaneModeEnabled;

@end
