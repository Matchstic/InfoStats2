//
//  IS2Telephony.m
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import "IS2Telephony.h"
#import <SpringBoard7.0/SBTelephonyManager.h> // TODO: Fix for iOS 5
#import <SpringBoard/SBWiFiManager.h>
#import <objc/runtime.h>

@implementation IS2Telephony

+(int)phoneSignalBars {
    return (int)[(SBTelephonyManager*)[objc_getClass("SBTelephonyController") sharedTelephonyManager] signalStrengthBars];
}

+(int)phoneSignalRSSI {
    return (int)[[objc_getClass("SBTelephonyController") sharedTelephonyManager] signalStrength];
}

+(NSString*)phoneCarrier {
    return [[objc_getClass("SBTelephonyController") sharedTelephonyManager] operatorName];
}

+(BOOL)airplaneModeEnabled {
    return [[objc_getClass("SBTelephonyController") sharedTelephonyManager] isInAirplaneMode];
}

+(int)wifiSignalBars {
    return [(SBWiFiManager*)[objc_getClass("SBWiFIManager") sharedInstance] signalStrengthBars];
}

+(int)wifiSignalRSSI {
    return [(SBWiFiManager*)[objc_getClass("SBWiFIManager") sharedInstance] signalStrengthRSSI];
}

+(BOOL)wifiEnabled {
    return [(SBWiFiManager*)[objc_getClass("SBWiFIManager") sharedInstance] isPowered];
}

+(NSString*)wifiName {
    return [(SBWiFiManager*)[objc_getClass("SBWiFIManager") sharedInstance] currentNetworkName];
}

@end
