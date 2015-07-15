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

// Wireless etc
+(int)phoneSignalBars;
+(int)phoneSignalRSSI;
+(NSString*)phoneCarrier;
+(BOOL)wifiEnabled;
+(int)wifiSignalBars;
+(int)wifiSignalRSSI;
+(NSString*)wifiName;
+(BOOL)airplaneModeEnabled;

@end
