//
//  IS2Telephony.h
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import <Foundation/Foundation.h>

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
