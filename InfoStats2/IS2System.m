//
//  IS2System.m
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import "IS2System.h"
#import <mach/mach.h>
#import <SpringBoard7.0/SBUIController.h>
#import <mach/mach_host.h>
#include <sys/sysctl.h>
#import <objc/runtime.h>
#import "IS2Extensions.h"
#import <SpringBoard8.1/SBUserAgent.h>
#import <SpringBoard6.0/SpringBoard.h>
#import <SpringBoard7.0/SBAssistantController.h>

@implementation IS2System

#pragma mark Battery

+(int)batteryPercent {
    return [(SBUIController*)[objc_getClass("SBUIController") sharedInstance] displayBatteryCapacityAsPercentage];
}

+(int)batteryStateAsInteger {
    return [UIDevice currentDevice].batteryState;
}

+(NSString*)batteryState {
    switch ([IS2System batteryStateAsInteger]) {
        case UIDeviceBatteryStateUnplugged: {
            return [[IS2Private stringsBundle] localizedStringForKey:@"UNPLUGGED" value:@"Unplugged" table:nil];
            break;
        }
            
        case UIDeviceBatteryStateCharging: {
            return [[IS2Private stringsBundle] localizedStringForKey:@"CHARGING" value:@"Charging" table:nil];
            break;
        }
            
        case UIDeviceBatteryStateFull: {
            return [[IS2Private stringsBundle] localizedStringForKey:@"FULL_CHARGED" value:@"Fully Charged" table:nil];
            break;
        }
            
        default: {
            return [[IS2Private stringsBundle] localizedStringForKey:@"UNKNOWN" value:@"Unknown" table:nil];
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

#pragma mark System functions

+(void)takeScreenshot {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This function isn't implemented yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

+(void)lockDevice {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This function isn't implemented yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

+(void)openSwitcher {
    [[objc_getClass("SBUIController") sharedInstance] _toggleSwitcher];
}

+(void)openApplication:(NSString*)bundleIdentifier {
    [[objc_getClass("SBUserAgent") sharedUserAgent] launchApplicationFromSource:2 withDisplayID:bundleIdentifier options:nil];
}

+(void)openSiri {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        [[objc_getClass("SBAssistantController") sharedInstance] _activateSiriForPPT];
    else {
        // TODO: Handle this for iOS 6
        [[objc_getClass("SBAssistantController") sharedInstance] activateIgnoringTouches];
    }
}

+(void)respring {
    [(SpringBoard*)[UIApplication sharedApplication] _relaunchSpringBoardNow];
}

+(void)reboot {
    [(SpringBoard*)[UIApplication sharedApplication] reboot];
}

@end
