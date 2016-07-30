//
//  IS2System.m
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import "IS2System.h"
#include <mach/mach.h>
#import <SpringBoard7.0/SBUIController.h>
#import <mach/mach_host.h>
#include <sys/sysctl.h>
#import <objc/runtime.h>
#import "IS2Extensions.h"
#import <SpringBoard8.1/SBUserAgent.h>
#import <SpringBoard6.0/SpringBoard.h>
#import <SpringBoard7.0/SBAssistantController.h>
#import <AudioToolbox/AudioToolbox.h>
#import <sys/utsname.h>
#include <sys/types.h>
#include <mach/processor_info.h>

@interface SBScreenShotter : NSObject
+ (id)sharedInstance;
- (void)saveScreenshot:(BOOL)arg1;
@end

@interface FBSystemService : NSObject
+ (id)sharedInstance;
- (void)exitAndRelaunch:(bool)arg1;
- (void)shutdownAndReboot:(bool)arg1;
@end

@interface SBMainSwitcherViewController : NSObject
+ (id)sharedInstance;
- (_Bool)toggleSwitcherNoninteractively;
@end

@interface SBScreenshotManager : NSObject
- (void)saveScreenshotsWithCompletion:(id)arg1;
@end

@interface SpringBoard (Screenshots)
@property(readonly, nonatomic) SBScreenshotManager *screenshotManager;
@end

void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID,id arg,NSDictionary* vibratePattern);

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

static processor_info_array_t cpuInfo, prevCpuInfo;
static mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
static unsigned numCPUs;
static NSLock *CPUUsageLock;

@implementation IS2System

+(void)setupAfterTweakLoaded {
    int mib[2U] = { CTL_HW, HW_NCPU };
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
    if(status)
        numCPUs = 1;
    
    CPUUsageLock = [[NSLock alloc] init];
}

#pragma mark Battery

+(int)batteryPercent {
    SBUIController *controller = (SBUIController*)[objc_getClass("SBUIController") sharedInstance];
    
    if ([controller respondsToSelector:@selector(displayBatteryCapacityAsPercentage)])
        return [controller displayBatteryCapacityAsPercentage];
    else
        return [controller batteryCapacityAsPercentage];
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

+(int)ramPhysical {
    return [self ramDataForType:-1];
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
    } else if (type == -1) {
        return (int)[self getSysInfo:HW_PHYSMEM] / giga;
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

#pragma mark System data

+(NSString*)deviceType {
    NSMutableString *string = [@"" mutableCopy];
    
    for (int i = 0; i < [IS2System deviceModel].length-1; i++) {
        if (isdigit([[IS2System deviceModel] characterAtIndex:i])) {
            break;
        } else {
            [string appendFormat:@"%c", [[IS2System deviceModel] characterAtIndex:i]];
        }
    }
    
    return string;
}

+(NSString*)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *machineName = [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];
    return machineName;
}

+(int)deviceDisplayHeight {
    return MAX(SCREEN_HEIGHT, SCREEN_WIDTH);
}

+(int)deviceDisplayWidth {
    return MIN(SCREEN_HEIGHT, SCREEN_WIDTH);
}

+(BOOL)isDeviceIn24Time {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24Hour = amRange.location == NSNotFound && pmRange.location == NSNotFound;
    return is24Hour;
}

#pragma mark System functions

+(void)takeScreenshot {
    if (objc_getClass("SBScreenShotter") && [[objc_getClass("SBScreenShotter") sharedInstance] respondsToSelector:@selector(saveScreenshot:)]) {
       [[objc_getClass("SBScreenShotter") sharedInstance] saveScreenshot:YES];
    }
    
    // Handle for iOS 9.3+.
    else if (objc_getClass("SBScreenshotManager")) {
        SBScreenshotManager *manager = [(SpringBoard*)[UIApplication sharedApplication] screenshotManager];
        
        [manager saveScreenshotsWithCompletion:nil];
    }
}

+(void)lockDevice {
    [[objc_getClass("SBUserAgent") sharedUserAgent] lockAndDimDevice];
}

+(void)openSwitcher {
    if ([[objc_getClass("SBUIController")sharedInstance] respondsToSelector:@selector(_toggleSwitcher)]) {
        [[objc_getClass("SBUIController") sharedInstance] _toggleSwitcher];
        
    // Handle for iOS 9.3+.
    } else if (objc_getClass("SBMainSwitcherViewController") && [[objc_getClass("SBMainSwitcherViewController") sharedInstance] respondsToSelector:@selector(toggleSwitcherNoninteractively)]) {
        [[objc_getClass("SBMainSwitcherViewController") sharedInstance] toggleSwitcherNoninteractively];
    }
}

+(void)openApplication:(NSString*)bundleIdentifier {
    [[objc_getClass("SBUserAgent") sharedUserAgent] launchApplicationFromSource:2 withDisplayID:bundleIdentifier options:nil];
}

+(void)openSiri {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        [[objc_getClass("SBAssistantController") sharedInstance] _activateSiriForPPT];
    else {
        // TODO: Test this for iOS 6
        [[objc_getClass("SBAssistantController") sharedInstance] activateIgnoringTouches];
    }
}

+(void)respring {
    // Handle 9.3+ for FrontBoard.
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(_relaunchSpringBoardNow)]) {
        [(SpringBoard*)[UIApplication sharedApplication] _relaunchSpringBoardNow];
    } else if (objc_getClass("FBSystemService") && [[objc_getClass("FBSystemService") sharedInstance] respondsToSelector:@selector(exitAndRelaunch:)]) {
        [[objc_getClass("FBSystemService") sharedInstance] exitAndRelaunch:YES];
    }
}

+(void)reboot {
    // Handle 9.3+ for FrontBoard.
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(reboot)]) {
        [(SpringBoard*)[UIApplication sharedApplication] reboot];
    } else if (objc_getClass("FBSystemService") && [[objc_getClass("FBSystemService") sharedInstance] respondsToSelector:@selector(shutdownAndReboot:)]) {
        [[objc_getClass("FBSystemService") sharedInstance] shutdownAndReboot:YES];
    }
}

+(void)vibrateDevice {
    [IS2System vibrateDeviceForTimeLength:0.2];
}

+(void)vibrateDeviceForTimeLength:(CGFloat)timeLength {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableArray* arr = [NSMutableArray array ];
    
    [arr addObject:[NSNumber numberWithBool:YES]]; //vibrate for time length
    [arr addObject:[NSNumber numberWithInt:timeLength*1000]];
    
    [arr addObject:[NSNumber numberWithBool:NO]];
    [arr addObject:[NSNumber numberWithInt:50]];
    
    [dict setObject:arr forKey:@"VibePattern"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
    
    AudioServicesPlaySystemSoundWithVibration(4095, nil, dict);
}

+(double)cpuUsage {
    natural_t numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    
    double usage = 0.0;
    
    if(err == KERN_SUCCESS) {
        [CPUUsageLock lock];
        
        for(unsigned i = 0U; i < numCPUs; ++i) {
            float inUse, totalTicks;
            if(prevCpuInfo) {
                
                float userDiff = (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]);
                float systemDiff = (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM]);
                float niceDiff = (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]);
                float idleDiff = (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
                
                inUse = (userDiff + systemDiff + niceDiff);
                totalTicks = inUse + idleDiff;
            } else {
                inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                totalTicks = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            
            usage += inUse / totalTicks;
        }
        
        [CPUUsageLock unlock];
        
        if(prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        
        cpuInfo = NULL;
        numCpuInfo = 0U;
        
        usage *= 100.0;
        usage /= numCPUsU;
    }
    
    if (usage == NAN) usage = 0.0;
    
    return usage;
}

+(uint64_t)freeDiskSpaceinBytesForPath:(NSString*)path {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error = nil;
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:&error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    } else {
        NSLog(@"[InfoStats2 | System] :: Failed to read storage data: %@", [error localizedDescription]);
    }
    
    return totalFreeSpace;
}

+(double)freeDiskSpaceInFormat:(int)format {
    uint64_t bytes = [self freeDiskSpaceinBytesForPath:@"/"];
    uint64_t mobile = [self freeDiskSpaceinBytesForPath:@"/var/mobile/"];
    
    bytes += mobile;
    
    switch (format) {
        case 1: // kb
            return (double)bytes / 1024.f;
            break;
        case 2: // MB
            return (double)bytes / 1024.f / 1024.f;
            break;
        case 3: // GB
            return (double)bytes / 1024.f / 1024.f / 1024.f;
            break;
        case 0: // Bytes
        default:
            return (double)bytes;
            break;
    }
}

// TODO: Implement these somehow.
+(double)networkSpeedUp {
    return 0.0;
}

+(double)networkSpeedDown {
    return 0.0;
}

@end
