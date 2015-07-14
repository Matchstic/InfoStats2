//
//  IS2System.h
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import <Foundation/Foundation.h>

@interface IS2System : NSObject

// Battery
+(int)batteryPercent;
+(NSString*)batteryState; // This is pre-translated for you
+(int)batteryStateAsInteger; // Shouldn't really need this, but it's available

// RAM - all values in MB
+(int)ramFree; // Free RAM = free + inactive (inactive is treated as free by iOS)
+(int)ramUsed;
+(int)ramAvailable;

// System utilities
+(void)takeScreenshot;
+(void)lockDevice;
+(void)openSwitcher;
+(void)openApplication:(NSString*)bundleIdentifier;

@end
