//
//  IS2Extensions.m
//  InfoStats2
//
//  Created by Matt Clarke on 01/06/2015.
//

#import "IS2Extensions.h"
#import "IS2WeatherProvider.h"
#import <SpringBoard7.0/SBUIController.h>
#import <SpringBoard7.0/SBTelephonyManager.h> // TODO: Fix for iOS 5
#import <SpringBoard/SBWiFiManager.h>
#import <objc/runtime.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#include <sys/sysctl.h>

static NSBundle *bundle; // strings bundle.
static SBTelephonyManager *telephonyManager;
static NSMutableSet *weatherUpdateBlockQueue;

@implementation IS2Extensions

#pragma mark Internal

+(void)initializeExtensions {
    bundle = [NSBundle bundleWithPath:@"/Library/Application Support/InfoStats2/Localisable.bundle"];
    
    if ([objc_getClass("SBTelephonyManager") respondsToSelector:@selector(sharedInstance)]) {
        telephonyManager = [objc_getClass("SBTelephonyController") sharedInstance];
    } else if ([objc_getClass("SBTelephonyManager") respondsToSelector:@selector(sharedTelephonyManager)]) {
        telephonyManager = [objc_getClass("SBTelephonyController") sharedTelephonyManager];
    }
    
    weatherUpdateBlockQueue = [NSMutableSet set];
}

#pragma mark Battery

+(int)batteryPercent {
    return [(SBUIController*)[objc_getClass("SBUIController") sharedInstance] displayBatteryCapacityAsPercentage];
}

+(int)batteryStateAsInteger {
    return [UIDevice currentDevice].batteryState;
}

+(NSString*)batteryState {
    switch ([IS2Extensions batteryStateAsInteger]) {
        case UIDeviceBatteryStateUnplugged: {
            return [bundle localizedStringForKey:@"UNPLUGGED" value:@"Unplugged" table:nil];
            break;
        }
            
        case UIDeviceBatteryStateCharging: {
            return [bundle localizedStringForKey:@"CHARGING" value:@"Charging" table:nil];
            break;
        }
            
        case UIDeviceBatteryStateFull: {
            return [bundle localizedStringForKey:@"FULL_CHARGED" value:@"Fully Charged" table:nil];
            break;
        }
            
        default: {
            return [bundle localizedStringForKey:@"UNKNOWN" value:@"Unknown" table:nil];
            break;
        }
    }
}

#pragma mark RAM

+(int)ramFree {
    return [self ramDataForType:1];
}

+(int)ramUsed {
    return [self ramDataForType:2];
}

+(int)ramAvailable {
    return [self ramDataForType:0];
}

+(int)ramDataForType:(int)type {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
    
    /* Stats in bytes */
    NSUInteger giga = 1024*1024;

    if (type == 0) {
        return (int)[self getSysInfo:HW_USERMEM] / giga;
    }
    
    natural_t wired = vm_stat.wire_count * (natural_t)pagesize / (1024 * 1024);
    natural_t active = vm_stat.active_count * (natural_t)pagesize / (1024 * 1024);
    natural_t inactive = vm_stat.inactive_count * (natural_t)pagesize / (1024 * 1024);
    if (type == 1) {
        return vm_stat.free_count * (natural_t)pagesize / (1024 * 1024) + inactive; // Inactive is treated as free by iOS
    } else {
        return active + wired;
    }
}

+(NSUInteger)getSysInfo:(uint)typeSpecifier {
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

#pragma mark Telephony

+(int)phoneSignalBars {
    return (int)[telephonyManager signalStrengthBars];
}

+(int)phoneSignalRSSI {
    return (int)[telephonyManager signalStrength];
}

+(NSString*)phoneCarrier {
    return [telephonyManager operatorName];
}

+(BOOL)airplaneModeEnabled {
    return [telephonyManager isInAirplaneMode];
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

#pragma mark Weather

+(int)currentTemperature {
    return [[IS2WeatherProvider sharedInstance] currentTemperature];
}

+(NSString*)currentLocation {
    return [[IS2WeatherProvider sharedInstance] currentLocation];
}

+(int)currentCondition {
    return [[IS2WeatherProvider sharedInstance] currentCondition];
}

+(NSString*)currentConditionAsString {
    return [[IS2WeatherProvider sharedInstance] currentConditionAsString];
}

+(int)highForCurrentDay {
    return [[IS2WeatherProvider sharedInstance] highForCurrentDay];
}

+(int)lowForCurrentDay {
    return [[IS2WeatherProvider sharedInstance] lowForCurrentDay];
}

+(int)currentWindSpeed {
    return [[IS2WeatherProvider sharedInstance] currentWindSpeed];
}

+(int)currentDewPoint {
    return [[IS2WeatherProvider sharedInstance] currentDewPoint];
}

+(int)currentHumidity {
    return [[IS2WeatherProvider sharedInstance] currentHumidity];
}

+(id)city {
    return [[IS2WeatherProvider sharedInstance] city];
}

+(int)currentWindChill {
    
}

+(int)currentVisibilityPercent {
    
}

+(int)currentChanceOfRain {
    
}

+(int)currentlyFeelsLike {
    
}

+(NSString*)sunsetTime {
    
}

+(NSString*)sunriseTime {
    
}

+(NSString*)lastUpdateTime {
    
}

+(NSArray*)dayForecastsForCurrentLocation {
    return [[IS2WeatherProvider sharedInstance] dayForecastsForCurrentLocation];
}

+(NSArray*)hourlyForecastsForCurrentLocation {
    return [[IS2WeatherProvider sharedInstance] hourlyForecastsForCurrentLocation];
}

+(BOOL)isWeatherUpdating {
    return [[IS2WeatherProvider sharedInstance] isUpdating];
}

+(void)updateWeatherWithCallback:(void (^)(void))callbackBlock {
    if (callbackBlock)
        [weatherUpdateBlockQueue addObject:[callbackBlock copy]];
    
    if (![[IS2WeatherProvider sharedInstance] isUpdating]) {
        // Update weather, and then call blocks for updated weather.
        [[IS2WeatherProvider sharedInstance] updateWeatherWithCallback:^{
            for (void (^block)() in weatherUpdateBlockQueue) {
                [block invoke]; // Runs all the callbacks whom requested a weather update.
            }
        }];
    }
}

#pragma mark Calendar

#pragma mark Alarms

#pragma mark Reminders

#pragma mark Music

#pragma mark System utilities

+(void)takeScreenshot {
    
}

+(void)lockDevice {
    
}

+(void)openSwitcher {
    
}

+(void)openApplication:(NSString*)bundleIdentifier {
    
}

@end
