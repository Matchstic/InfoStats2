//
//  IS2Notifications.m
//  InfoStats2
//
//  Created by Matt Clarke on 23/07/2015.
//
//

#import "IS2Notifications.h"
#import "IS2WorkaroundDictionary.h"
#import "IS2Extensions.h"
#import <objc/runtime.h>

@interface BBAction : NSObject
+(instancetype)action;
@end

@interface SBIconModel : NSObject
-(NSArray*)visibleIconIdentifiers;
@end

@interface SBIconViewMap : NSObject
+(instancetype)homescreenMap; // Not in 9.3!
-(SBIconModel*)iconModel;
@end

@interface SBIconController : NSObject
+(instancetype)sharedInstance;
@property(readonly, nonatomic) SBIconViewMap *homescreenIconViewMap;
@end

@interface SBApplicationIcon : NSObject
- (id)initWithApplication:(id)arg1;
-(id)badgeNumberOrString;
-(void)setBadge:(id)arg1;
@end

@interface SBApplication : NSObject
-(void)setBadge:(id)arg1;
-(id)badgeNumberOrString;
@end

@interface SBBannerController : NSObject
+(instancetype)sharedInstance;
-(BOOL)isShowingBanner;
-(void)_replaceIntervalElapsed;
-(void)_dismissIntervalElapsed;
@end

@interface SBUserAgent : NSObject
+(id)sharedUserAgent;
- (BOOL)lockScreenIsShowing;
@end

@interface SBApplicationController : NSObject
+(instancetype)sharedInstance;
-(SBApplication*)applicationWithDisplayIdentifier:(NSString*)identifier;
-(SBApplication*)applicationWithBundleIdentifier:(NSString *)identifier;
@end

@interface BBBulletin : NSObject
@property(copy) NSString *bulletinID;
@property bool clearable;
@property(retain) NSDate *date;
@property(copy) BBAction *defaultAction;
@property(retain) NSDate *lastInterruptDate;
@property(copy) NSString *message;
@property(retain) NSDate *publicationDate;
@property(copy) NSString *sectionID;
@property bool showsMessagePreview;
@property(copy) NSString *title;
@end

@interface BBServer : NSObject
+(instancetype)IS2_sharedInstance;
-(void)publishBulletin:(BBBulletin*)arg1 destinations:(int)arg2 alwaysToLockScreen:(BOOL)arg3;
-(id)_allBulletinsForSectionID:(id)arg1;
@end

@interface SBBulletinBannerController : NSObject
+(instancetype)sharedInstance;
-(void)observer:(id)arg1 addBulletin:(BBBulletin*)arg2 forFeed:(int)arg3;
-(void)observer:(id)arg1 addBulletin:(BBBulletin*)arg2 forFeed:(int)arg3 playLightsAndSirens:(BOOL)arg4 withReply:(id)arg5;
@end

static NSMutableDictionary *ncNotificationCounts;
static NSMutableDictionary *badgeNotificationCounts;
static NSMutableDictionary *lockscreenBulletins;
static IS2WorkaroundDictionary *notificationUpdateQueue;
static int notificationPublishedCount = 0;

@implementation IS2Notifications

#pragma mark Private methods

// From Protean: https://github.com/mlnlover11/Protean/blob/master/PRStatusApps.mm
inline int bestCountForApp(NSString *identifier) {
    if (identifier == nil || [identifier isEqualToString:@""]) return 0;
    
    int ncCount = [ncNotificationCounts[identifier] intValue];
    int badgeCount = [badgeNotificationCounts[identifier] intValue];
    return MAX(ncCount, badgeCount);
}

+(void)setupAfterTweakLoaded {
    ncNotificationCounts = [NSMutableDictionary dictionary];
    badgeNotificationCounts = [NSMutableDictionary dictionary];
    notificationUpdateQueue = [IS2WorkaroundDictionary dictionary];
    lockscreenBulletins = [NSMutableDictionary dictionary];
    [lockscreenBulletins setObject:[NSMutableDictionary dictionary] forKey:@"countDictionary"];
}

// I used to cut corners in this function...
+(void)setupAfterSpringBoardLaunched {
    // Setup badge counts for first run
    
    SBIconViewMap *map = nil;
    if ([objc_getClass("SBIconViewMap") respondsToSelector:@selector(homescreenMap)]) {
        map = [objc_getClass("SBIconViewMap") homescreenMap];
    } else if ([[objc_getClass("SBIconController") sharedInstance] respondsToSelector:@selector(homescreenIconViewMap)]) {
        map = [[objc_getClass("SBIconController") sharedInstance] homescreenIconViewMap];
    }
    
    NSLog(@"*** [InfoStats 2 | Notifications] :: GOT HOMESCREEN VIEW MAP: %@, AND IDENTIFIERS:\n%@", map, [[map iconModel] visibleIconIdentifiers]);
    
    NSArray *appIcons = [[map iconModel] visibleIconIdentifiers];
    for (NSString *identifier in appIcons) {
        id cls = [objc_getClass("SBApplicationController") sharedInstance];
        SBApplication *app = nil;
        if ([cls respondsToSelector:@selector(applicationWithDisplayIdentifier:)])
            app = [cls applicationWithDisplayIdentifier:identifier];
        else
            app = [cls applicationWithBundleIdentifier:identifier];
        
        id badgeNumberOrString = nil;
        int badgeCount = 0;
        
        if ([app respondsToSelector:@selector(badgeNumberOrString)]) {
            badgeNumberOrString = [app badgeNumberOrString];
        } else {
            SBApplicationIcon *icon = [[objc_getClass("SBApplicationIcon") alloc] initWithApplication:app];
            badgeNumberOrString = [icon badgeNumberOrString];
        }
        
        badgeCount = [badgeNumberOrString intValue];
        
        [self updateBadgeCountWithIdentifier:identifier andValue:badgeCount];
    }
}

+(void)updateNCCountWithIdentifier:(NSString*)identifier andValue:(int)value {
    [ncNotificationCounts setObject:[NSNumber numberWithInt:value] forKey:identifier];
    [IS2Notifications notifyCallbacksOfDataChange];
}

+(void)updateBadgeCountWithIdentifier:(NSString*)identifier andValue:(int)value {
    [badgeNotificationCounts setObject:[NSNumber numberWithInt:value] forKey:identifier];
    [IS2Notifications notifyCallbacksOfDataChange];
}

+(void)updateLockscreenCountWithBulletin:(BBBulletin*)bulletin isRemoval:(BOOL)isRemoval isModification:(BOOL)isMod {
    if (!isRemoval) {
        [lockscreenBulletins setObject:bulletin forKey:bulletin.bulletinID];
    } else {
        [lockscreenBulletins removeObjectForKey:bulletin.bulletinID];
    }
    
    NSMutableDictionary *countDict = lockscreenBulletins[@"countDictionary"];
    int oldCount = [[countDict objectForKey:bulletin.sectionID] intValue];
    
    if (isRemoval) oldCount -= 1;
    else if (!isMod) oldCount += 1;
    
    [countDict setObject:[NSNumber numberWithInt:oldCount] forKey:bulletin.sectionID];
}

+(void)removeLockscreenCountsForUnlock {
    [lockscreenBulletins removeAllObjects];
    [lockscreenBulletins setObject:[NSMutableDictionary dictionary] forKey:@"countDictionary"];
}

+(void)notifyCallbacksOfDataChange {
    for (void (^block)() in [notificationUpdateQueue allValues]) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            block(); // Runs all the callbacks.
        });
    }
}

+(void)publishBulletin:(BBBulletin*)bulletin onLockscreen:(BOOL)onLockscreen {
    if (onLockscreen) {
        [[objc_getClass("BBServer") IS2_sharedInstance] publishBulletin:bulletin destinations:4 alwaysToLockScreen:YES];
    } else {
        SBBannerController *controller = [objc_getClass("SBBannerController") sharedInstance];
        if ([controller isShowingBanner]) { // Don't do anything if there is already a banner showing.
            return;
        }
        // Not sure if these are needed - see TinyBar.
        [NSObject cancelPreviousPerformRequestsWithTarget:controller
                                                 selector:@selector(_replaceIntervalElapsed)
                                                   object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:controller
                                                 selector:@selector(_dismissIntervalElapsed)
                                                   object:nil];
        [controller _replaceIntervalElapsed];
        [controller _dismissIntervalElapsed];
        SBBulletinBannerController *bc = [objc_getClass("SBBulletinBannerController") sharedInstance];
        if ([bc respondsToSelector:@selector(observer:addBulletin:forFeed:)]) {
            [bc observer:nil addBulletin:bulletin forFeed:2];
        } else if ([bc respondsToSelector:@selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:)]) {
            [bc observer:nil addBulletin:bulletin forFeed:2 playLightsAndSirens:YES withReply:nil];
        }
    }
}

#pragma mark Public methods

+(void)registerForBulletinNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock {
    if (!notificationUpdateQueue) {
        notificationUpdateQueue = [IS2WorkaroundDictionary dictionary];
    }
    
    if (callbackBlock && identifier) {
        [notificationUpdateQueue addObject:callbackBlock forKey:identifier];
    }
}

+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier {
    [notificationUpdateQueue removeObjectForKey:identifier];
}

+(int)notificationCountForApplication:(NSString*)bundleIdentifier {
    return bestCountForApp(bundleIdentifier);
}

+(int)lockscreenNotificationCountForApplication:(NSString*)bundleIdentifier {
    NSDictionary *countDict = [lockscreenBulletins objectForKey:@"countDictionary"];
    return [countDict[bundleIdentifier] intValue];
}

+(int)totalNotificationCountOnLockScreenOnly:(BOOL)onLockscreenOnly {
    if (onLockscreenOnly) {
        return (int)lockscreenBulletins.count - 1; // -1 to remove count dictionary
    } else {
        // For each bundle id stored, count up. First, work out list of bundle IDs from the two dictionaries.
        NSMutableArray *bundleIdentifiers = [NSMutableArray arrayWithArray:ncNotificationCounts.allKeys];
        
        for (NSString *iden in badgeNotificationCounts.allKeys) {
            if (![bundleIdentifiers containsObject:iden]) {
                [bundleIdentifiers addObject:iden];
            }
        }
        
        int count = 0;
        
        for (NSString *bundleIdentifier in bundleIdentifiers) {
            count += bestCountForApp(bundleIdentifier);
        }
        
        return count;
    }
}

+(NSArray*)notificationsForApplication:(NSString*)bundleIdentifier {
    NSArray *notifs = [[objc_getClass("BBServer") IS2_sharedInstance] _allBulletinsForSectionID:bundleIdentifier];
    notifs = (notifs != nil ? notifs : [NSArray array]);
    return notifs;
}

+(NSString*)notificationsJSONForApplication:(NSString*)bundleIdentifier {
    NSMutableString *string = [@"[" mutableCopy];
    
    NSArray *entries = [IS2Notifications notificationsForApplication:bundleIdentifier];
    
    int i = 0;
    for (BBBulletin *bulletin in entries) {
        i++;
        [string appendString:@"{"];
        
        [string appendFormat:@"\"title\":\"%@\",", [IS2Private JSONescapedStringForString:bulletin.title]];
        [string appendFormat:@"\"message\":\"%@\",", [IS2Private JSONescapedStringForString:bulletin.message]];
        [string appendFormat:@"\"bundleIdentifier\":\"%@\",", bulletin.sectionID];
        [string appendFormat:@"\"timeFired\":%ld", (time_t)bulletin.date.timeIntervalSince1970 * 1000];
        
        [string appendFormat:@"}%@", (i == entries.count ? @"" : @",")];
    }
    
    [string appendString:@"]"];
    
    return string;
}

+(void)publishBulletinWithTitle:(NSString *)title message:(NSString *)message andBundleIdentifier:(NSString *)bundleIdentifier {
    if (!bundleIdentifier || [bundleIdentifier isEqualToString:@""])
        bundleIdentifier = @"com.apple.Preferences";
    
    BBBulletin *bulletin = [[objc_getClass("BBBulletin") alloc] init];
    bulletin.title = title;
    bulletin.message = message;
    bulletin.sectionID = bundleIdentifier;
    bulletin.defaultAction = (BBAction*)[objc_getClass("BBAction") action];
    bulletin.bulletinID = [NSString stringWithFormat:@"IS2%lu%d", (unsigned long)[message hash], notificationPublishedCount];
    bulletin.showsMessagePreview = YES;
    bulletin.clearable = YES;
    bulletin.date = [NSDate date];
    bulletin.publicationDate = [NSDate date];
    bulletin.lastInterruptDate = [NSDate date];
    
    [IS2Notifications publishBulletin:bulletin onLockscreen:[[objc_getClass("SBUserAgent") sharedUserAgent] lockScreenIsShowing]];
    
    notificationPublishedCount++;
}

@end
