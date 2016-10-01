//
//  IS2System.m
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import "IS2System.h"
#include <mach/mach.h>
#import <mach/mach_host.h>
#include <sys/sysctl.h>
#import <objc/runtime.h>
#import "IS2Extensions.h"
#import <AudioToolbox/AudioToolbox.h>
#import <sys/utsname.h>
#include <sys/types.h>
#include <mach/processor_info.h>
#import <dlfcn.h>
#import <Foundation/NSProcessInfo.h>


//////////////////////////////////////////////////////////////
// For network speeds

#import <sys/socket.h>
#import <sys/types.h>
#import <mach/mach_time.h>
#import <net/if.h>
#import <net/if_var.h>
#import <net/if_dl.h>

typedef struct {
    uint64_t timestamp;
    uint64_t totalDownloadBytes;
    uint64_t totalUploadBytes;
} NetSample;

#define	RTM_IFINFO2 		0x12 /* route.h */
/////////////////////////////////////////////////////////////

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

@interface SpringBoard : UIApplication
@property(readonly, nonatomic) SBScreenshotManager *screenshotManager;
-(void)_relaunchSpringBoardNow;
-(void)reboot;
@end

@interface SBUserAgent : NSObject
+(id)sharedUserAgent;
- (void)lockAndDimDevice;
- (_Bool)launchApplicationFromSource:(int)arg1 withDisplayID:(id)arg2 options:(id)arg3;
@end

@interface SBUIController : NSObject
+(id)sharedInstance;
-(int)batteryCapacityAsPercentage;
-(int)displayBatteryCapacityAsPercentage; // Older API.
-(void)_toggleSwitcher;
@end

@interface SBAssistantController : NSObject
+(id)sharedInstance;
-(void)_activateSiriForPPT;
-(void)activateIgnoringTouches;
@end

@interface NSProcessInfo (IOS9)
@property(readonly, getter=isLowPowerModeEnabled) BOOL lowPowerModeEnabled;
@end

@interface _CDBatterySaver : NSObject
+ (id)batterySaver;
- (long long)getPowerMode;
- (long long)setMode:(long long)arg1;
- (bool)setPowerMode:(long long)arg1 error:(id*)arg2;
@end

@interface SBLockScreenViewController : NSObject
- (_Bool)isPasscodeLockVisible;
@end

@interface SBLockScreenManager : NSObject
+(id)sharedInstance;
@property(readonly, nonatomic) SBLockScreenViewController *lockScreenViewController;
@end

@interface UIImage (Private)
+(id)_applicationIconImageForBundleIdentifier:(NSString*)displayIdentifier format:(int)form scale:(CGFloat)scale;
@end

typedef NS_ENUM(NSUInteger, PLWallpaperMode) {
    PLWallpaperModeBoth,
    PLWallpaperModeHomeScreen,
    PLWallpaperModeLockScreen
};

typedef NS_ENUM(NSUInteger, IS2WallpaperVariant) {
    IS2WallpaperVariantLockScreen,
    IS2WallpaperVariantHomeScreen
};

@interface PLWallpaperImageViewController : UIViewController
- (instancetype)initWithWallpaperVariant:(int)arg1;
- (instancetype)initWithUIImage:(UIImage*)arg1;
@end

@interface PLStaticWallpaperImageViewController : PLWallpaperImageViewController
- (void)setWallpaperForLocations:(long long)arg1;
@end

void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID,id arg,NSDictionary* vibratePattern);

#if __cplusplus
extern "C" {
#endif
void BKSHIDServicesSetBacklightFactorWithFadeDuration(float factor, int duration);
float BKSDisplayBrightnessGetCurrent();
void BKSDisplayBrightnessSet(float level, int __unknown0);
typedef struct BKSDisplayBrightnessTransaction *BKSDisplayBrightnessTransactionRef;
    
/* Follows the 'Create' rule. */
BKSDisplayBrightnessTransactionRef BKSDisplayBrightnessTransactionCreate(CFAllocatorRef allocator);
#if __cplusplus
}
#endif

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

static processor_info_array_t cpuInfo, prevCpuInfo;
static mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
static unsigned numCPUs;
static NSLock *CPUUsageLock;

// For network data.
static NetSample lastNetSample;
static NSTimer *netUpdater;
static double download;
static double upload;

// For wallpaper access.
static PLWallpaperImageViewController *cachedHomescreenWallpaper;
static PLWallpaperImageViewController *cachedLockscreenWallpaper;

@implementation IS2System

+(void)setupAfterTweakLoaded {
    int mib[2U] = { CTL_HW, HW_NCPU };
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
    if(status)
        numCPUs = 1;
    
    CPUUsageLock = [[NSLock alloc] init];
    
    [self _startUpdatingNetwork];
}

+(void)setupAfterSpringBoardLoaded {
    cachedHomescreenWallpaper = [self _wallpaperWithVariant:1];
    cachedLockscreenWallpaper = [self _wallpaperWithVariant:0];
}

+(PLWallpaperImageViewController*)_wallpaperWithVariant:(int)variant {
    PLWallpaperImageViewController *cont = [[objc_getClass("PLWallpaperImageViewController") alloc] initWithWallpaperVariant:variant];
    cont.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    UIView *cropView = [self traverseHierarchyForClass:objc_getClass("PLCropOverlay") andView:cont.view];
    UIView *dateView = [self traverseHierarchyForClass:objc_getClass("SBFLockScreenDateView") andView:cont.view];
    UIView *segmentControl = [self traverseHierarchyForClass:objc_getClass("SBSUIEffectsSegmentedControl") andView:cont.view];
    
    [cropView removeFromSuperview];
    [segmentControl removeFromSuperview];
    [dateView removeFromSuperview];
    
    cont.view.clipsToBounds = YES;
    cont.view.userInteractionEnabled = NO;
    
    return cont;
}

+(UIView*)traverseHierarchyForClass:(Class)cl andView:(UIView*)toTraverse {
    UIView *found = nil;
    
    for (UIView *view in toTraverse.subviews) {
        if (!found) {
            if ([view.class isEqual:cl]) {
                found = view;
                break;
            } else {
                found = [self traverseHierarchyForClass:cl andView:view];
            }
        } else {
            break;
        }
    }
    
    return found;
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

+(NSString*)deviceName {
    return [[UIDevice currentDevice] name];
}

+(NSString*)deviceType {
    return [[UIDevice currentDevice] model];
}

+(NSString*)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *machineName = [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];
    return machineName;
}

+(NSString*)deviceModelHumanReadable {
    NSString* code = [IS2System deviceModel];
    
    static NSDictionary* deviceNamesByCode = nil;

    if (!deviceNamesByCode) {

        deviceNamesByCode = @{@"i386"      :@"Simulator",
                              @"x86_64"    :@"Simulator",
                              @"iPod1,1"   :@"iPod Touch",        // (Original)
                              @"iPod2,1"   :@"iPod Touch",        // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch",        // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch",        // (Fourth Generation)
                              @"iPod7,1"   :@"iPod Touch",        // (6th Generation)       
                              @"iPhone1,1" :@"iPhone",            // (Original)
                              @"iPhone1,2" :@"iPhone 3G",            // (3G)
                              @"iPhone2,1" :@"iPhone 3GS",            // (3GS)
                              @"iPad1,1"   :@"iPad",              // (Original)
                              @"iPad2,1"   :@"iPad 2",            //
                              @"iPad3,1"   :@"iPad",              // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",          // (GSM)
                              @"iPhone3,3" :@"iPhone 4",          // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" :@"iPhone 4S",         //
                              @"iPhone5,1" :@"iPhone 5",          // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",          // (model A1429, everything else)
                              @"iPad3,4"   :@"iPad",              // (4th Generation)
                              @"iPad2,5"   :@"iPad Mini",         // (Original)
                              @"iPhone5,3" :@"iPhone 5c",         // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5c",         // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5s",         // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5s",         // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iPhone 6 Plus",     //
                              @"iPhone7,2" :@"iPhone 6",          //
                              @"iPhone8,1" :@"iPhone 6S",         //
                              @"iPhone8,2" :@"iPhone 6S Plus",    //
                              @"iPhone8,4" :@"iPhone SE",         //
                              @"iPhone9,1" :@"iPhone 7",          //
                              @"iPhone9,2" :@"iPhone 7 Plus",     //
                              @"iPhone9,3" :@"iPhone 7",          //
                              @"iPhone9,4" :@"iPhone 7 Plus",     //
                              @"iPad4,1"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPad Mini",         // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini",         // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,7"   :@"iPad Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
                              @"iPad6,7"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1584) 
                              @"iPad6,8"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1652) 
                              @"iPad6,3"   :@"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (model A1673)
                              @"iPad6,4"   :@"iPad Pro (9.7\")"   // iPad Pro 9.7 inches - (models A1674 and A1675)
                              };
    }

    NSString* deviceName = [deviceNamesByCode objectForKey:code];

    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:

        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
        else {
            deviceName = @"Unknown";
        }
    }

    return deviceName;
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
        NSLog(@"[InfoStats 2 | System] :: Failed to read storage data: %@", [error localizedDescription]);
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

+(uint64_t)totalDiskSpaceinBytesForPath:(NSString*)path {
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
        NSLog(@"[InfoStats 2 | System] :: Failed to read storage data: %@", [error localizedDescription]);
    }
    
    return totalSpace;
}

+(double)totalDiskSpaceInFormat:(int)format {
    uint64_t bytes = [self totalDiskSpaceinBytesForPath:@"/"];
    uint64_t mobile = [self totalDiskSpaceinBytesForPath:@"/var/mobile/"];
    
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

// These following network functions are making use of CCMeters; need to check with Sticktron this is okay to use.
// Source: https://github.com/cRazEYgUy/CCMeters
+(double)networkSpeedUp {
    return upload/1024.0f;
}

+(double)networkSpeedDown {
    return download/1024.0f;
}

+(NSString*)networkSpeedUpAutoConverted {
    return [self _formatBytes:upload];
}

+(NSString*)networkSpeedDownAutoConverted {
    return [self _formatBytes:download];
}

+(NSString *)_formatBytes:(double)bytes {
    NSString *result;
    
    if (bytes > (1024*1024*1024)) { // G
        result = [NSString stringWithFormat:@"%.1f GB/s", bytes/1024/1024/1024];
    } else if (bytes > (1024*1024)) { // M
        result = [NSString stringWithFormat:@"%.1f MB/s", bytes/1024/1024];
    } else if (bytes > 1024) { // K
        result = [NSString stringWithFormat:@"%.1f KB/s", bytes/1024];
    } else if (bytes > 0 ) {
        result = [NSString stringWithFormat:@"%.0f B/s", bytes];
    } else {
        result = @"0";
    }
    
    return result;
}

+(void)_startUpdatingNetwork {
    lastNetSample = [self _retrieveNetworkStatistics];
    netUpdater = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(_updateNetwork:) userInfo:nil repeats:YES];
}

+(void)_stopUpdatingNetwork {
    [netUpdater invalidate];
    netUpdater = nil;
}

+(void)_updateNetwork:(id)sender {
    NetSample net_delta;
    NetSample net_sample = [self _retrieveNetworkStatistics];
    
    // calculate period length
    net_delta.timestamp = (net_sample.timestamp - lastNetSample.timestamp);
    double interval = net_delta.timestamp / 1000.0 / 1000.0 / 1000.0; // ns-to-s
    
    // get bytes transferred since last sample was taken
    net_delta.totalUploadBytes = net_sample.totalUploadBytes - lastNetSample.totalUploadBytes;
    net_delta.totalDownloadBytes = net_sample.totalDownloadBytes - lastNetSample.totalDownloadBytes;
    
    upload = (double)net_delta.totalUploadBytes / interval;
    download = net_delta.totalDownloadBytes / interval;
    
    // save this sample for next time
    lastNetSample = net_sample;
}

+(NetSample)_retrieveNetworkStatistics {
    /*
     NetSample: { timestamp, totalUploadBytes, totalDownloadBytes }
     */
    NetSample sample = {0, 0, 0};
    
    int mib[] = {
        CTL_NET,
        PF_ROUTE,
        0,
        0,
        NET_RT_IFLIST2,
        0
    };
    
    size_t len = 0;
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) >= 0) {
        char *buf = (char *)malloc(len);
        
        if (sysctl(mib, 6, buf, &len, NULL, 0) >= 0) {
            
            // read interface stats ...
            
            char *lim = buf + len;
            char *next = NULL;
            u_int64_t totalibytes = 0;
            u_int64_t totalobytes = 0;
            char name[32];
            
            for (next = buf; next < lim; ) {
                struct if_msghdr *ifm = (struct if_msghdr *)next;
                next += ifm->ifm_msglen;
                
                if (ifm->ifm_type == RTM_IFINFO2) {
                    struct if_msghdr2 *if2m = (struct if_msghdr2 *)ifm;
                    struct sockaddr_dl *sdl = (struct sockaddr_dl *)(if2m + 1);
                    
                    strncpy(name, sdl->sdl_data, sdl->sdl_nlen);
                    name[sdl->sdl_nlen] = 0;
                    
                    NSString *interface = [NSString stringWithUTF8String:name];
                    //DebugLog(@"interface (%u) name=%@", if2m->ifm_index, interface);
                    
                    // skip local interface (lo0)
                    if (![interface isEqualToString:@"lo0"]) {
                        totalibytes += if2m->ifm_data.ifi_ibytes;
                        totalobytes += if2m->ifm_data.ifi_obytes;
                    }
                }
            }
            
            sample.timestamp = [self _timestamp];
            sample.totalUploadBytes = totalobytes;
            sample.totalDownloadBytes = totalibytes;
            
        } else {
            NSLog(@"[InfoStats 2 | System] :: Error in sysctl");
        }
        
        free(buf);
        
    } else {
        NSLog(@"[InfoStats 2 | System] :: Error in sysctl");
    }
    
    return sample;
}

+(uint64_t)_timestamp {
    
    // get timer units
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    
    // get timer value
    uint64_t timestamp = mach_absolute_time();
    
    // convert to nanoseconds
    timestamp *= info.numer;
    timestamp /= info.denom;
    
    return timestamp;
}

#pragma mark Toggles and such like

+(CGFloat)getBrightness {
    return (CGFloat)BKSDisplayBrightnessGetCurrent();
}

+(void)setBrightness:(CGFloat)level {
    // This function now utilises code from https://github.com/k3a/AutoBrightness/blob/master/main.m
    
    BOOL useBackBoardServices = (kCFCoreFoundationVersionNumber >= 1140.10);
    
    if (useBackBoardServices) {
        BKSDisplayBrightnessTransactionRef transaction = BKSDisplayBrightnessTransactionCreate(kCFAllocatorDefault);
        BKSDisplayBrightnessSet((float)level, 1);
        CFRelease(transaction);
    } else {
        static int (*SBSSpringBoardServerPort)() = 0;
        static void (*SBSetCurrentBacklightLevel)(int _port, float level) = 0;
        
        if (SBSSpringBoardServerPort == NULL) {
            void *uikit = dlopen("/System/Library/Framework/UIKit.framework/UIKit", RTLD_LAZY);
            SBSSpringBoardServerPort = (int (*)())dlsym(uikit, "SBSSpringBoardServerPort");
            SBSetCurrentBacklightLevel = (void (*)(int,float))dlsym(uikit, "SBSetCurrentBacklightLevel");
        }
        
        int port = SBSSpringBoardServerPort();
        SBSetCurrentBacklightLevel(port, (float)level);
    }
    
    /*if (level >= 0 && level <= 1) {
        [[UIScreen mainScreen] setBrightness:level];
    }
    else if (level > 1 && level <= 100) {
        level = level / 100
        [[UIScreen mainScreen] setBrightness:level];
    }*/
}

+(BOOL)getLowPowerMode {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        return [[NSProcessInfo processInfo] isLowPowerModeEnabled];
    } else {
        return NO;
    }
}

+(void)setLowPowerMode:(BOOL)mode {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        // Cannot apply this on less than iOS 9.
        return;
    }
    
    _CDBatterySaver *batterySaver = [objc_getClass("_CDBatterySaver") batterySaver];
    int newMode;
    if (mode) {
        newMode = 1;
        [batterySaver setMode:1];
    } else {
        newMode = 0;
        [batterySaver setMode:0];
    }
    NSError *error = nil;
    if (![batterySaver setPowerMode:newMode error:&error]) {
        NSLog(@"[InfoStats 2 | System] :: Failed to set low power mode: %@", error);
    }
}

#warning This *will not* work on iOS 6
#warning Add docs
+(BOOL)isLockscreenPasscodeVisible {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        // TODO: Add correct function for iOS 6.
        return NO;
    } else {
        return [[[objc_getClass("SBLockScreenManager") sharedInstance] lockScreenViewController] isPasscodeLockVisible];
    }
}

#warning Add docs
+(UIImage*)getApplicationIconForBundleIdentifier:(NSString*)bundleIdentifier {
    return [UIImage _applicationIconImageForBundleIdentifier:bundleIdentifier format:2 scale:[UIScreen mainScreen].scale];
}

#warning Add docs
+(NSString*)getApplicationIconForBundleIdentifierBase64:(NSString*)bundleIdentifier {
	UIImage *img = [IS2System getApplicationIconForBundleIdentifier:bundleIdentifier];
    if (img) {
        @try {
            NSData *imageData = UIImagePNGRepresentation(img);
            return [NSString stringWithFormat:@"data:image/png;base64,%@", [imageData base64Encoding]];
        } @catch (NSException *e) {
            return @"data:image/png;base64,";
        }
    } else {
        return @"data:image/png;base64,";
    }
}

#warning Add docs
+(void)setWallpaperWithBase64Image:(NSString*)img forMode:(int)mode {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:img options:0];
    UIImage *image = [UIImage imageWithData:data];
    PLStaticWallpaperImageViewController *wallpaperViewController = [[objc_getClass("PLStaticWallpaperImageViewController") alloc] initWithUIImage:image];
    
    [wallpaperViewController setWallpaperForLocations:(long long)mode];
}

+(void)setWallpaperWithImage:(UIImage*)img forMode:(int)mode {
    PLStaticWallpaperImageViewController *wallpaperViewController = [[objc_getClass("PLStaticWallpaperImageViewController") alloc] initWithUIImage:img];
    
    [wallpaperViewController setWallpaperForLocations:(long long)mode];
}

#warning Add docs
+(UIImage*)getWallpaperForVariant:(int)variant {
    UIView *view = nil;
    
    if (variant) {
        view = cachedHomescreenWallpaper.view;
    } else {
        view = cachedLockscreenWallpaper.view;
    }
    
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [view setNeedsDisplay];
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, YES, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
 
#warning Add docs
+(NSString*)getWallpaperForVariantBase64:(int)variant {
	UIImage *img = [IS2System getWallpaperForVariant:variant];
	if (img) {
		@try {
			NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
			return [NSString stringWithFormat:@"data:image/jpeg;base64,%@", [imageData base64Encoding]];
		} @catch (NSException *e) {
			return @"data:image/jpeg;base64,";
        }
	} else {
		return @"data:image/jpeg;base64,";
	}
}

@end
