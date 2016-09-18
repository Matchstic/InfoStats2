//
//  IS2Private.m
//  InfoStats2
//
//  Created by Matt Clarke on 01/06/2015.
//

#import "IS2Extensions.h"
#import "IS2WeatherProvider.h"
#import "IS2System.h"
#include <notify.h>
#include <sys/stat.h>

#define LEGACY 1

@interface IS2Calendar : NSObject
+(void)setupAfterTweakLoad;
@end

@interface IS2System (additions)
+(void)setupAfterTweakLoaded;
+(int)ramPhysical;
@end

@interface IS2Notifications : NSObject
+(void)setupAfterTweakLoaded;
+(void)setupAfterSpringBoardLaunched;
@end

@interface IS2Location : NSObject
+(void)setupAfterTweakLoaded;
@end

@interface IS2Pedometer : NSObject
+(void)setupAfterSpringBoardLaunched;
+(void)setupAfterTweakLoaded;
+(void)significantTimeChange; // TODO
@end

static NSBundle *bundle; // strings bundle.
static IS2Private *instance;
static int displayToken;

@implementation IS2Private

#pragma mark Internal

+(NSBundle*)stringsBundle {
    if (!bundle) {
        bundle = [NSBundle bundleWithPath:@"/Library/Application Support/InfoStats2/Localisable.bundle"];
    }
    
    return bundle;
}

+(void)setupForTweakLoaded {
    [[IS2WeatherProvider sharedInstance] setupForTweakLoaded];
    [IS2Calendar setupAfterTweakLoad];
    [IS2Notifications setupAfterTweakLoaded];
    [IS2Location setupAfterTweakLoaded];
    [IS2System setupAfterTweakLoaded];
    
    // Add pedometer support for iOS 9+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        [IS2Pedometer setupAfterTweakLoaded];
    }
}

+(void)setupAfterSpringBoardLoaded {
    [IS2Notifications setupAfterSpringBoardLaunched];
    
    // Add pedometer support for iOS 9+
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 9.0)
        [IS2Pedometer setupAfterSpringBoardLaunched];
    
#if (LEGACY)
    // Force IS1 support to begin running.
    [[IS2Private sharedInstance] updateIS1AfterSleep];
#endif
}

+(NSString*)JSONescapedStringForString:(NSString*)input {
    NSMutableString *s = [NSMutableString stringWithString:input];
    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

+(instancetype)sharedInstance {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        instance = [[self alloc] init];
        notify_register_check("com.matchstic.infostats2/displayUpdate", &displayToken);
    });
    
    // returns the same object each time
    return instance;
}

#if (LEGACY)
-(instancetype)init {
    self = [super init];
    
    if (self) {
        // Setup ram and battery timers for IS1 legacy support.
        _ramtimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(IS1RamChanged) userInfo:nil repeats:YES];
        _batterytimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(IS1BatteryChanged) userInfo:nil repeats:YES];
        
        // And also get notified when the battery state changes.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IS1BatteryStateChanged:) name:@"UIDeviceBatteryStateDidChangeNotification" object:[UIDevice currentDevice]];
    }
    
    return self;
}
#endif

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)performBlockOnMainThread:(void (^)(void))callbackBlock {
    callbackBlock();
}

-(void)setScreenOffState:(BOOL)screenState {
    _screenState = screenState;
    
#if (LEGACY)
    if (!screenState) {
        [self updateIS1AfterSleep];
    }
#endif
    
    notify_set_state(displayToken, (int)screenState);
    notify_post("com.matchstic.infostats2/displayUpdate");
}

-(BOOL)getIsScreenOff {
    return _screenState;
}

#pragma mark Stuff used for IS1 support. This is pretty much lifted from the legacy code.

#if (LEGACY)
-(void)updateIS1AfterSleep {
    [self IS1RamChanged];
    [self IS1BatteryChanged];
}

-(void)IS1RamChanged {
    // Check if file exists, create if not
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Stats/RAMStats.txt"]) {
        mkdir("/var/mobile/Library/Stats/", 0755);
        system("touch /var/mobile/Library/Stats/RAMStats.txt");
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/RAMStats.txt"]) {
        system("ln -s '/var/mobile/Library/Stats/RAMStats.txt' '/var/mobile/Library/RAMStats.txt'");
    }
    
    NSMutableArray *lines = [NSMutableArray array];
    
    // Free
    [lines addObject:[NSString stringWithFormat:@"Free: %d", [IS2System ramFree]]];
    
    // Used
    [lines addObject:[NSString stringWithFormat:@"Used: %d", [IS2System ramUsed]]];
    
    // Total usable
    [lines addObject:[NSString stringWithFormat:@"Total usable: %d", [IS2System ramAvailable]]];
    
    // Total physical
    [lines addObject:[NSString stringWithFormat:@"Total physical: %d", [IS2System ramPhysical]]];
    
    [self IS1WriteArray:lines toFile:@"/var/mobile/Library/Stats/RAMStats.txt"];
}

-(void)IS1BatteryStateChanged:(id)sender {
    [self IS1BatteryChanged];
}

-(void)IS1BatteryChanged {
    // Called for both charging state changes and for level changes.

    // Check if file exists, create if not
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Stats/BatteryStats.txt"]) {
        mkdir("/var/mobile/Library/Stats/", 0755);
        system("touch /var/mobile/Library/Stats/BatteryStats.txt");
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/BatteryStats.txt"]) {
        system("ln -s '/var/mobile/Library/Stats/BatteryStats.txt' '/var/mobile/Library/BatteryStats.txt'");
    }
    
    NSMutableArray *lines = [NSMutableArray array];
    
    // Free
    [lines addObject:[NSString stringWithFormat:@"Level: %d", [IS2System batteryPercent]]];
    
    // Used
    [lines addObject:[NSString stringWithFormat:@"State: %@", [IS2System batteryState]]];
    
    // Total usable
    [lines addObject:[NSString stringWithFormat:@"State-Raw: %d", [IS2System batteryStateAsInteger]]];
    
    [self IS1WriteArray:lines toFile:@"/var/mobile/Library/Stats/BatteryStats.txt"];
}

-(void)IS1WriteArray:(NSArray*)array toFile:(NSString*)filepath {
    NSString *write = [array componentsJoinedByString:@"\n"];
    
    NSError *error;
    [write writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"*** [InfoStats2 | Legacy] :: Failed to write to '%@', with error:\n'%@'", filepath, error);
    }
}
#endif

@end
