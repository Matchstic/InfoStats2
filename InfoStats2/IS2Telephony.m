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
#import "Reachability.h"

@implementation IS2Telephony

+(int)phoneSignalBars {
    return (int)[(SBTelephonyManager*)[objc_getClass("SBTelephonyManager") sharedTelephonyManager] signalStrengthBars];
}

+(int)phoneSignalRSSI {
    return (int)[[objc_getClass("SBTelephonyManager") sharedTelephonyManager] signalStrength];
}

+(NSString*)phoneCarrier {
    return [[objc_getClass("SBTelephonyManager") sharedTelephonyManager] operatorName];
}

+(BOOL)airplaneModeEnabled {
    return [[objc_getClass("SBTelephonyManager") sharedTelephonyManager] isInAirplaneMode];
}

+(int)wifiSignalBars {
    return [(SBWiFiManager*)[objc_getClass("SBWiFiManager") sharedInstance] signalStrengthBars];
}

+(int)wifiSignalRSSI {
    return [(SBWiFiManager*)[objc_getClass("SBWiFiManager") sharedInstance] signalStrengthRSSI];
}

+(BOOL)wifiEnabled {
    return [(SBWiFiManager*)[objc_getClass("SBWiFiManager") sharedInstance] isPowered];
}

+(NSString*)wifiName {
    return [(SBWiFiManager*)[objc_getClass("SBWiFiManager") sharedInstance] currentNetworkName];
}

// Data shizzle

+(BOOL)dataConnectionAvailable {
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    return reach.isReachable;
}

+(BOOL)dataConnectionAvailableViaWiFi {
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    return reach.isReachableViaWiFi;
}



@end
