#line 1 "/Users/Matt/iOS/Projects/InfoStats2/InfoStats2/InfoStats2.xm"
#import <objc/runtime.h>
#include "WebCycript.h"
#import <UIKit/UIKit.h>
#include <typeinfo> 
#include <JavaScriptCore/JSContextRef.h> 
#include <JavaScriptCore/JSObjectRef.h> 







static bool _ZL15All_hasPropertyPK15OpaqueJSContextP13OpaqueJSValueP14OpaqueJSString(JSContextRef, JSObjectRef, JSStringRef);

@class WebScriptObject;

@interface UIWebDocumentView : UIView
-(WebView*)webView;
@end

@interface WebFrame : NSObject
-(id)dataSource;
- (OpaqueJSContext*)globalContext;
@end

@interface WebView : NSObject
-(void)setPreferencesIdentifier:(id)arg1;
-(void)_setAllowsMessaging:(BOOL)arg1;
-(WebFrame*)mainFrame;
@end

@interface UIWebView (Apple)
- (void)webView:(WebView *)view addMessageToConsole:(NSDictionary *)message;
- (void)webView:(WebView *)webview didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame;
-(UIWebDocumentView*)_documentView;
@end

@protocol IS2Delegate <NSObject>
- (void)webView:(WebView *)webview didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame;
@end

@interface IS2Private : NSObject
+(void)setupForTweakLoaded;
+(void)setupAfterSpringBoardLoaded;
+(instancetype)sharedInstance;
-(void)setScreenOffState:(BOOL)screenState;
@end

@interface IS2Media : NSObject
+(void)nowPlayingDataDidUpdate;
@end

@interface BBBulletin : NSObject
@property(copy) NSString *sectionID;
@end

@interface IS2Notifications : NSObject
+(void)updateNCCountWithIdentifier:(NSString*)identifier andValue:(int)value;
+(void)updateBadgeCountWithIdentifier:(NSString*)identifier andValue:(int)value;
+(int)notificationCountForApplication:(NSString*)bundleIdentifier;
+(void)updateLockscreenCountWithBulletin:(BBBulletin*)bulletin isRemoval:(BOOL)isRemoval isModification:(BOOL)isMod;
+(void)removeLockscreenCountsForUnlock;
@end

@interface SBApplication : NSObject
- (id)bundleIdentifier;
- (id)badgeNumberOrString;
@end

@interface SBApplicationIcon : NSObject
-(id)badgeNumberOrString;
-(SBApplication*)application;
@end

@interface SBAwayBulletinListItem : NSObject
@property(strong) BBBulletin *activeBulletin;
@end

@interface NCNotificationRequest : NSObject
@property (nonatomic, readonly) BBBulletin *bulletin;
@end

@interface BBServer : NSObject
- (id)allBulletinIDsForSectionID:(id)arg1;
@end

@interface MPUNowPlayingController : NSObject
- (void)_updateCurrentNowPlaying;
- (void)_updateNowPlayingAppDisplayID;
- (void)_updatePlaybackState;
- (void)_updateTimeInformationAndCallDelegate:(BOOL)arg1;
- (BOOL)currentNowPlayingAppIsRunning;
- (id)nowPlayingAppDisplayID;
- (double)currentDuration;
- (double)currentElapsed;
@end

@interface IWWidget : UIView {
    UIWebView *_webView;
}
- (void)webView:(id)arg1 didClearWindowObject:(id)arg2 forFrame:(id)arg3;
@end




#pragma mark Injection of Cycript into WebViews


















#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SBLockScreenNotificationListController; @class SBApplicationIcon; @class UIWebView; @class IWWidget; @class BBServer; @class SBAwayBulletinListController; @class SBLockScreenViewController; @class MPUNowPlayingController; @class SpringBoard; @class SBDashBoardViewController; @class SBAwayController; @class SBApplication; @class UIView; 
static UIWebView* (*_logos_orig$_ungrouped$UIWebView$initWithFrame$)(_LOGOS_SELF_TYPE_INIT UIWebView*, SEL, CGRect) _LOGOS_RETURN_RETAINED; static UIWebView* _logos_method$_ungrouped$UIWebView$initWithFrame$(_LOGOS_SELF_TYPE_INIT UIWebView*, SEL, CGRect) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$UIWebView$webView$addMessageToConsole$)(_LOGOS_SELF_TYPE_NORMAL UIWebView* _LOGOS_SELF_CONST, SEL, WebView *, NSDictionary *); static void _logos_method$_ungrouped$UIWebView$webView$addMessageToConsole$(_LOGOS_SELF_TYPE_NORMAL UIWebView* _LOGOS_SELF_CONST, SEL, WebView *, NSDictionary *); static void (*_logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$)(_LOGOS_SELF_TYPE_NORMAL UIWebView* _LOGOS_SELF_CONST, SEL, WebView *, WebScriptObject *, WebFrame *); static void _logos_method$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$(_LOGOS_SELF_TYPE_NORMAL UIWebView* _LOGOS_SELF_CONST, SEL, WebView *, WebScriptObject *, WebFrame *); static void (*_logos_orig$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$)(_LOGOS_SELF_TYPE_NORMAL IWWidget* _LOGOS_SELF_CONST, SEL, id, id, id); static void _logos_method$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$(_LOGOS_SELF_TYPE_NORMAL IWWidget* _LOGOS_SELF_CONST, SEL, id, id, id); static id _logos_method$_ungrouped$UIView$_newCloseBoxOfType$(_LOGOS_SELF_TYPE_NORMAL UIView* _LOGOS_SELF_CONST, SEL, int); static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static MPUNowPlayingController* (*_logos_orig$_ungrouped$MPUNowPlayingController$init)(_LOGOS_SELF_TYPE_INIT MPUNowPlayingController*, SEL) _LOGOS_RETURN_RETAINED; static MPUNowPlayingController* _logos_method$_ungrouped$MPUNowPlayingController$init(_LOGOS_SELF_TYPE_INIT MPUNowPlayingController*, SEL) _LOGOS_RETURN_RETAINED; static double _logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_elapsedTime(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static double _logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_currentDuration(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static BOOL _logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_currentNowPlayingAppIsRunning(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static id _logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_nowPlayingAppDisplayID(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBApplication$setBadge$)(_LOGOS_SELF_TYPE_NORMAL SBApplication* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SBApplication$setBadge$(_LOGOS_SELF_TYPE_NORMAL SBApplication* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$SBApplicationIcon$setBadge$)(_LOGOS_SELF_TYPE_NORMAL SBApplicationIcon* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SBApplicationIcon$setBadge$(_LOGOS_SELF_TYPE_NORMAL SBApplicationIcon* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForAddition$)(_LOGOS_SELF_TYPE_NORMAL SBAwayBulletinListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *); static void _logos_method$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForAddition$(_LOGOS_SELF_TYPE_NORMAL SBAwayBulletinListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *); static void (*_logos_orig$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForModification$originalHeight$)(_LOGOS_SELF_TYPE_NORMAL SBAwayBulletinListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *, float); static void _logos_method$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForModification$originalHeight$(_LOGOS_SELF_TYPE_NORMAL SBAwayBulletinListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *, float); static void (*_logos_orig$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForRemoval$originalHeight$)(_LOGOS_SELF_TYPE_NORMAL SBAwayBulletinListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *, float); static void _logos_method$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForRemoval$originalHeight$(_LOGOS_SELF_TYPE_NORMAL SBAwayBulletinListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *, float); static void (*_logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForAdditionOfItem$)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *); static void _logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForAdditionOfItem$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *); static void (*_logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForReplacingItem$withNewItem$)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *, SBAwayBulletinListItem *); static void _logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForReplacingItem$withNewItem$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *, SBAwayBulletinListItem *); static void (*_logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForModificationOfItem$)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *); static void _logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForModificationOfItem$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *); static void (*_logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelForRemovalOfItem$updateView$)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *, BOOL); static void _logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelForRemovalOfItem$updateView$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST, SEL, SBAwayBulletinListItem *, BOOL); static void (*_logos_orig$_ungrouped$SBDashBoardViewController$postNotificationRequest$forCoalescedNotification$)(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, NCNotificationRequest*, id); static void _logos_method$_ungrouped$SBDashBoardViewController$postNotificationRequest$forCoalescedNotification$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, NCNotificationRequest*, id); static void (*_logos_orig$_ungrouped$SBDashBoardViewController$updateNotificationRequest$forCoalescedNotification$)(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, NCNotificationRequest*, id); static void _logos_method$_ungrouped$SBDashBoardViewController$updateNotificationRequest$forCoalescedNotification$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, NCNotificationRequest*, id); static void (*_logos_orig$_ungrouped$SBDashBoardViewController$withdrawNotificationRequest$forCoalescedNotification$)(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, NCNotificationRequest*, id); static void _logos_method$_ungrouped$SBDashBoardViewController$withdrawNotificationRequest$forCoalescedNotification$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, NCNotificationRequest*, id); static void (*_logos_orig$_ungrouped$SBDashBoardViewController$deactivate)(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBDashBoardViewController$deactivate(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBDashBoardViewController$setInScreenOffMode$forAutoUnlock$)(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, _Bool, _Bool); static void _logos_method$_ungrouped$SBDashBoardViewController$setInScreenOffMode$forAutoUnlock$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST, SEL, _Bool, _Bool); static void (*_logos_orig$_ungrouped$SBLockScreenViewController$_releaseLockScreenView)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBLockScreenViewController$_releaseLockScreenView(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOnWhileUILocked$)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOnWhileUILocked$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOn)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOn(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOff)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOff(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBAwayController$_releaseAwayView)(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBAwayController$_releaseAwayView(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBAwayController$undimScreen)(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBAwayController$undimScreen(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBAwayController$undimScreen$)(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$_ungrouped$SBAwayController$undimScreen$(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST, SEL, BOOL); static void (*_logos_orig$_ungrouped$SBAwayController$dimScreen$)(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$_ungrouped$SBAwayController$dimScreen$(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST, SEL, BOOL); static id _logos_meta_method$_ungrouped$BBServer$IS2_sharedInstance(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static BBServer* (*_logos_orig$_ungrouped$BBServer$init)(_LOGOS_SELF_TYPE_INIT BBServer*, SEL) _LOGOS_RETURN_RETAINED; static BBServer* _logos_method$_ungrouped$BBServer$init(_LOGOS_SELF_TYPE_INIT BBServer*, SEL) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$)(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, __unsafe_unretained BBBulletin*, unsigned long long, _Bool); static void _logos_method$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, __unsafe_unretained BBBulletin*, unsigned long long, _Bool); static void (*_logos_orig$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$)(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, __unsafe_unretained NSSet*, unsigned long long, _Bool); static void _logos_method$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, __unsafe_unretained NSSet*, unsigned long long, _Bool); 

#line 126 "/Users/Matt/iOS/Projects/InfoStats2/InfoStats2/InfoStats2.xm"


static UIWebView* _logos_method$_ungrouped$UIWebView$initWithFrame$(_LOGOS_SELF_TYPE_INIT UIWebView* self, SEL _cmd, CGRect frame) _LOGOS_RETURN_RETAINED {
    UIWebView *original = _logos_orig$_ungrouped$UIWebView$initWithFrame$(self, _cmd, frame);
        
    UIWebDocumentView *document = [original _documentView];
    WebView *webview = [document webView];
        
    [webview setPreferencesIdentifier:@"WebCycript"];
        
    if ([webview respondsToSelector:@selector(_setAllowsMessaging:)])
        [webview _setAllowsMessaging:YES];
    
    
    
    
    return original;
}


static void _logos_method$_ungrouped$UIWebView$webView$addMessageToConsole$(_LOGOS_SELF_TYPE_NORMAL UIWebView* _LOGOS_SELF_CONST self, SEL _cmd, WebView * view, NSDictionary * message) {
    NSLog(@"[InfoStats2] :: addMessageToConsole: %@", message);
    
    if ([UIWebView instancesRespondToSelector:@selector(webView:addMessageToConsole:)])
        _logos_orig$_ungrouped$UIWebView$webView$addMessageToConsole$(self, _cmd, view, message);
}


static void _logos_method$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$(_LOGOS_SELF_TYPE_NORMAL UIWebView* _LOGOS_SELF_CONST self, SEL _cmd, WebView * webview, WebScriptObject * window, WebFrame * frame) {
    
    
    if ([[self class] isEqual:[objc_getClass("CydgetWebView") class]] ||
        [[self class] isEqual:[objc_getClass("GLWebView") class]] ||
        [[self class] isEqual:[objc_getClass("CVLockHTMLBackgroundView") class]]) {
        
        _logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$(self, _cmd, webview, window, frame);
        return;
    }
    
    NSString *href = [[[[frame dataSource] request] URL] absoluteString];
    if (href) {
        
        @try {
            WebCycriptSetupView(webview);
            NSLog(@"[InfoStats2] :: Cycript was injected into an instance of %@", [self class]);
        } @catch (NSException *e) {
            NSLog(@"[InfoStats2] :: Exception in Cycript injection => %@", e);
        }
    }
    
    _logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$(self, _cmd, webview, window, frame);
}



#pragma mark Needed to inject into iWidgets



static void _logos_method$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$(_LOGOS_SELF_TYPE_NORMAL IWWidget* _LOGOS_SELF_CONST self, SEL _cmd, id arg1, id arg2, id arg3) {
    UIWebView *webView = MSHookIvar<UIWebView*>(self, "_webView");
    [webView webView:arg1 didClearWindowObject:arg2 forFrame:arg3];
    
    _logos_orig$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$(self, _cmd, arg1, arg2, arg3);
}








static id _logos_method$_ungrouped$UIView$_newCloseBoxOfType$(_LOGOS_SELF_TYPE_NORMAL UIView* _LOGOS_SELF_CONST self, SEL _cmd, int type) {
    return nil;
}



#pragma mark Hooks needed for data access

#pragma mark Finished loading notifier



static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST self, SEL _cmd, id application) {
    _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);
    
    [IS2Private setupAfterSpringBoardLoaded];
}



#pragma mark Media















static MPUNowPlayingController * __weak globalMPUNowPlaying;




static MPUNowPlayingController* _logos_method$_ungrouped$MPUNowPlayingController$init(_LOGOS_SELF_TYPE_INIT MPUNowPlayingController* self, SEL _cmd) _LOGOS_RETURN_RETAINED {
    id orig = _logos_orig$_ungrouped$MPUNowPlayingController$init(self, _cmd);
    
    globalMPUNowPlaying = orig;
    
    return orig;
}


static double _logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_elapsedTime(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST self, SEL _cmd) {
    return [globalMPUNowPlaying currentElapsed];
}


static double _logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_currentDuration(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST self, SEL _cmd) {
    return [globalMPUNowPlaying currentElapsed];
}


static BOOL _logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_currentNowPlayingAppIsRunning(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST self, SEL _cmd) {
    return [globalMPUNowPlaying currentNowPlayingAppIsRunning];
}


static id _logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_nowPlayingAppDisplayID(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST self, SEL _cmd) {
    return [globalMPUNowPlaying nowPlayingAppDisplayID];
}



#pragma mark Notifications




static void _logos_method$_ungrouped$SBApplication$setBadge$(_LOGOS_SELF_TYPE_NORMAL SBApplication* _LOGOS_SELF_CONST self, SEL _cmd, id arg1) {
    _logos_orig$_ungrouped$SBApplication$setBadge$(self, _cmd, arg1);
    
    int badgeCount = 0;
    
    if ([self respondsToSelector:@selector(badgeNumberOrString)])
        badgeCount = [[self badgeNumberOrString] intValue];
        
    NSString *ident = [self bundleIdentifier];
    [IS2Notifications updateBadgeCountWithIdentifier:ident andValue:badgeCount];
    
    
}






static void _logos_method$_ungrouped$SBApplicationIcon$setBadge$(_LOGOS_SELF_TYPE_NORMAL SBApplicationIcon* _LOGOS_SELF_CONST self, SEL _cmd, id arg1) {
    _logos_orig$_ungrouped$SBApplicationIcon$setBadge$(self, _cmd, arg1);
    
    if ([[UIDevice currentDevice] systemVersion].floatValue < 7.0) {
        int badgeCount = 0;
    
        if ([self respondsToSelector:@selector(badgeNumberOrString)])
            badgeCount = [[self badgeNumberOrString] intValue];
        
        NSString *ident = [[self application] bundleIdentifier];
        [IS2Notifications updateBadgeCountWithIdentifier:ident andValue:badgeCount];
    
        
    }
}





 

static void _logos_method$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForAddition$(_LOGOS_SELF_TYPE_NORMAL SBAwayBulletinListController* _LOGOS_SELF_CONST self, SEL _cmd, SBAwayBulletinListItem * listItem) {
    if ([[listItem class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:listItem.activeBulletin isRemoval:NO isModification:NO];
    }
    _logos_orig$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForAddition$(self, _cmd, listItem);
}

static void _logos_method$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForModification$originalHeight$(_LOGOS_SELF_TYPE_NORMAL SBAwayBulletinListController* _LOGOS_SELF_CONST self, SEL _cmd, SBAwayBulletinListItem * arg1, float arg2) {
    if ([[arg1 class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:arg1.activeBulletin isRemoval:NO isModification:YES];
    }
    _logos_orig$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForModification$originalHeight$(self, _cmd, arg1, arg2);
}

static void _logos_method$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForRemoval$originalHeight$(_LOGOS_SELF_TYPE_NORMAL SBAwayBulletinListController* _LOGOS_SELF_CONST self, SEL _cmd, SBAwayBulletinListItem * arg1, float arg2) {
    if ([[arg1 class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:arg1.activeBulletin isRemoval:YES isModification:NO];
    }
    _logos_orig$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForRemoval$originalHeight$(self, _cmd, arg1, arg2);
}



 

static void _logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForAdditionOfItem$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST self, SEL _cmd, SBAwayBulletinListItem * listItem) {
    
    if ([[listItem class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:listItem.activeBulletin isRemoval:NO isModification:NO];
    }
    
    _logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForAdditionOfItem$(self, _cmd, listItem);
}

static void _logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForReplacingItem$withNewItem$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST self, SEL _cmd, SBAwayBulletinListItem * arg1, SBAwayBulletinListItem * arg2) {
    if ([[arg2 class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:arg2.activeBulletin isRemoval:NO isModification:YES];
    }
    
    _logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForReplacingItem$withNewItem$(self, _cmd, arg1, arg2);
}

static void _logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForModificationOfItem$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST self, SEL _cmd, SBAwayBulletinListItem * arg1) {
    if ([[arg1 class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:arg1.activeBulletin isRemoval:NO isModification:YES];
    }
    _logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForModificationOfItem$(self, _cmd, arg1);
}

static void _logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelForRemovalOfItem$updateView$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenNotificationListController* _LOGOS_SELF_CONST self, SEL _cmd, SBAwayBulletinListItem * arg1, BOOL arg2) {
    if ([[arg1 class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:arg1.activeBulletin isRemoval:YES isModification:NO];
    }
    _logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelForRemovalOfItem$updateView$(self, _cmd, arg1, arg2);
}



 

static void _logos_method$_ungrouped$SBDashBoardViewController$postNotificationRequest$forCoalescedNotification$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST self, SEL _cmd, NCNotificationRequest* arg1, id arg2) {
    [IS2Notifications updateLockscreenCountWithBulletin:arg1.bulletin isRemoval:NO isModification:NO];
    _logos_orig$_ungrouped$SBDashBoardViewController$postNotificationRequest$forCoalescedNotification$(self, _cmd, arg1, arg2);
}

static void _logos_method$_ungrouped$SBDashBoardViewController$updateNotificationRequest$forCoalescedNotification$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST self, SEL _cmd, NCNotificationRequest* arg1, id arg2) {
    [IS2Notifications updateLockscreenCountWithBulletin:arg1.bulletin isRemoval:NO isModification:YES];
    _logos_orig$_ungrouped$SBDashBoardViewController$updateNotificationRequest$forCoalescedNotification$(self, _cmd, arg1, arg2);
}

static void _logos_method$_ungrouped$SBDashBoardViewController$withdrawNotificationRequest$forCoalescedNotification$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST self, SEL _cmd, NCNotificationRequest* arg1, id arg2) {
    [IS2Notifications updateLockscreenCountWithBulletin:arg1.bulletin isRemoval:YES isModification:NO];
    _logos_orig$_ungrouped$SBDashBoardViewController$withdrawNotificationRequest$forCoalescedNotification$(self, _cmd, arg1, arg2);
}



#pragma mark Notify that unlocking has occured



static void _logos_method$_ungrouped$SBLockScreenViewController$_releaseLockScreenView(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST self, SEL _cmd) {
    _logos_orig$_ungrouped$SBLockScreenViewController$_releaseLockScreenView(self, _cmd);
    [IS2Notifications removeLockscreenCountsForUnlock];
}





static void _logos_method$_ungrouped$SBAwayController$_releaseAwayView(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST self, SEL _cmd) {
    _logos_orig$_ungrouped$SBAwayController$_releaseAwayView(self, _cmd);
    [IS2Notifications removeLockscreenCountsForUnlock];
}





static void _logos_method$_ungrouped$SBDashBoardViewController$deactivate(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST self, SEL _cmd) {
    _logos_orig$_ungrouped$SBDashBoardViewController$deactivate(self, _cmd);
    [IS2Notifications removeLockscreenCountsForUnlock];
}



static BBServer *sharedServer;








static id _logos_meta_method$_ungrouped$BBServer$IS2_sharedInstance(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST self, SEL _cmd) {
    return sharedServer;
}

static BBServer* _logos_method$_ungrouped$BBServer$init(_LOGOS_SELF_TYPE_INIT BBServer* self, SEL _cmd) _LOGOS_RETURN_RETAINED {
    sharedServer = _logos_orig$_ungrouped$BBServer$init(self, _cmd);
    return sharedServer;
}

static void _logos_method$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST self, SEL _cmd, __unsafe_unretained BBBulletin* arg1, unsigned long long arg2, _Bool arg3) {
    _logos_orig$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$(self, _cmd, arg1, arg2, arg3);
    
    NSArray *bulletins = [self allBulletinIDsForSectionID:arg1.sectionID];
    int count = (int)bulletins.count;
    [IS2Notifications updateNCCountWithIdentifier:[arg1.sectionID copy] andValue:count];
}

static void _logos_method$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST self, SEL _cmd, __unsafe_unretained NSSet* arg1, unsigned long long arg2, _Bool arg3) {
    _logos_orig$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$(self, _cmd, arg1, arg2, arg3);
    
    BBBulletin *bulletin = [arg1 anyObject];
    if (!bulletin)
        return;
    
    NSString *section = bulletin.sectionID;
    [IS2Notifications updateNCCountWithIdentifier:section andValue:[IS2Notifications notificationCountForApplication:section] - (int)arg1.count];
}



#pragma mark Display status




static void _logos_method$_ungrouped$SBDashBoardViewController$setInScreenOffMode$forAutoUnlock$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardViewController* _LOGOS_SELF_CONST self, SEL _cmd, _Bool arg1, _Bool arg2) {
    [[IS2Private sharedInstance] setScreenOffState:NO];
    _logos_orig$_ungrouped$SBDashBoardViewController$setInScreenOffMode$forAutoUnlock$(self, _cmd, arg1, arg2);
}






static void _logos_method$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOnWhileUILocked$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST self, SEL _cmd, id locked) {
    [[IS2Private sharedInstance] setScreenOffState:NO];
    
    _logos_orig$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOnWhileUILocked$(self, _cmd, locked);
}

static void _logos_method$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOn(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST self, SEL _cmd) {
    [[IS2Private sharedInstance] setScreenOffState:NO];
    
    _logos_orig$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOn(self, _cmd);
}

static void _logos_method$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOff(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewController* _LOGOS_SELF_CONST self, SEL _cmd) {
    _logos_orig$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOff(self, _cmd);
    
    [[IS2Private sharedInstance] setScreenOffState:YES];
}






static void _logos_method$_ungrouped$SBAwayController$undimScreen(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST self, SEL _cmd) {
    [[IS2Private sharedInstance] setScreenOffState:NO];
    
    _logos_orig$_ungrouped$SBAwayController$undimScreen(self, _cmd);
}

static void _logos_method$_ungrouped$SBAwayController$undimScreen$(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST self, SEL _cmd, BOOL arg1) {
    [[IS2Private sharedInstance] setScreenOffState:NO];
    
    _logos_orig$_ungrouped$SBAwayController$undimScreen$(self, _cmd, arg1);
}

static void _logos_method$_ungrouped$SBAwayController$dimScreen$(_LOGOS_SELF_TYPE_NORMAL SBAwayController* _LOGOS_SELF_CONST self, SEL _cmd, BOOL arg1) {
    _logos_orig$_ungrouped$SBAwayController$dimScreen$(self, _cmd, arg1);
    
    [[IS2Private sharedInstance] setScreenOffState:YES];
}



#pragma mark Hooks into libcycript ( :( )








static bool (*ori_All_hasProperty)(JSContextRef, JSObjectRef, JSStringRef);

MSHook(bool, All_hasProperty, JSContextRef context, JSObjectRef object, JSStringRef property) {
    try {
        return ori_All_hasProperty(context, object, property);
    } catch (std::bad_cast& bc) {
        NSLog(@"*** [InfoStats2 | Warning] :: Caught bad_cast in All_hasProperty");
        return false;
    } catch (...) {
        NSLog(@"*** [InfoStats2 | Warning] :: Caught unknown exception in All_hasProperty");
        return false;
    }
}


static JSObjectRef (*ori_CYCastJSObject)(JSContextRef, JSValueRef);

MSHook(JSObjectRef, CYCastJSObject, JSContextRef context, JSValueRef value) {
    try {
        return ori_CYCastJSObject(context, value);
    } catch (std::bad_cast& bc) {
        NSLog(@"*** [InfoStats2 | Warning] :: Caught bad_cast in CYCastJSObject");
        return JSObjectMake(context, NULL, NULL);
    } catch (...) {
        NSLog(@"*** [InfoStats2 | Warning] :: Caught unknown exception in CYCastJSObject");
        return JSObjectMake(context, NULL, NULL);
    }
}

static JSValueRef (*ori_CYCallAsFunction)(JSContextRef, JSObjectRef, JSObjectRef, size_t, const JSValueRef[]);

MSHook(JSValueRef, CYCallAsFunction, JSContextRef context, JSObjectRef function, JSObjectRef _this, size_t count, const JSValueRef arguments[]) {
    if (context == NULL || function == NULL) {
        NSLog(@"*** [InfoStats2 | Warning] :: Caught illegal arguments to CYCallAsFunction");
        
        
        JSValueRef (*CYJSNull)(JSContextRef) = (JSValueRef(*)(JSContextRef))MSFindSymbol(NULL, "__Z8CYJSNullPK15OpaqueJSContext");
        
        return CYJSNull(context);
    }
    
    try {
        return ori_CYCallAsFunction(context, function, _this, count, arguments);
    } catch (std::bad_cast& bc) {
        NSLog(@"*** [InfoStats2 | Warning] :: Caught bad_cast in CYCallAsFunction");
        
        
        JSValueRef (*CYJSNull)(JSContextRef) = (JSValueRef(*)(JSContextRef))MSFindSymbol(NULL, "__Z8CYJSNullPK15OpaqueJSContext");
        
        return CYJSNull(context);
    } catch (...) {
        NSLog(@"*** [InfoStats2 | Warning] :: Caught unknown exception in CYCallAsFunction");
        
        
        JSValueRef (*CYJSNull)(JSContextRef) = (JSValueRef(*)(JSContextRef))MSFindSymbol(NULL, "__Z8CYJSNullPK15OpaqueJSContext");
        
        return CYJSNull(context);
    }
}

#pragma mark Constructor

static __attribute__((constructor)) void _logosLocalCtor_71141b66(int argc, char **argv, char **envp) {
    
    dlopen("/Library/MobileSubstrate/DynamicLibraries/iWidgets.dylib", RTLD_NOW);
    
    {Class _logos_class$_ungrouped$UIWebView = objc_getClass("UIWebView"); if (_logos_class$_ungrouped$UIWebView) {MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(initWithFrame:), (IMP)&_logos_method$_ungrouped$UIWebView$initWithFrame$, (IMP*)&_logos_orig$_ungrouped$UIWebView$initWithFrame$);} else {HBLogError(@"logos: nil class %s", "UIWebView");}if (_logos_class$_ungrouped$UIWebView) {MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(webView:addMessageToConsole:), (IMP)&_logos_method$_ungrouped$UIWebView$webView$addMessageToConsole$, (IMP*)&_logos_orig$_ungrouped$UIWebView$webView$addMessageToConsole$);} else {HBLogError(@"logos: nil class %s", "UIWebView");}if (_logos_class$_ungrouped$UIWebView) {MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(webView:didClearWindowObject:forFrame:), (IMP)&_logos_method$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$, (IMP*)&_logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$);} else {HBLogError(@"logos: nil class %s", "UIWebView");}Class _logos_class$_ungrouped$IWWidget = objc_getClass("IWWidget"); if (_logos_class$_ungrouped$IWWidget) {MSHookMessageEx(_logos_class$_ungrouped$IWWidget, @selector(webView:didClearWindowObject:forFrame:), (IMP)&_logos_method$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$, (IMP*)&_logos_orig$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$);} else {HBLogError(@"logos: nil class %s", "IWWidget");}Class _logos_class$_ungrouped$UIView = objc_getClass("UIView"); { char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = 'i'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIView, @selector(_newCloseBoxOfType:), (IMP)&_logos_method$_ungrouped$UIView$_newCloseBoxOfType$, _typeEncoding); }Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); if (_logos_class$_ungrouped$SpringBoard) {MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);} else {HBLogError(@"logos: nil class %s", "SpringBoard");}Class _logos_class$_ungrouped$MPUNowPlayingController = objc_getClass("MPUNowPlayingController"); Class _logos_metaclass$_ungrouped$MPUNowPlayingController = object_getClass(_logos_class$_ungrouped$MPUNowPlayingController); if (_logos_class$_ungrouped$MPUNowPlayingController) {MSHookMessageEx(_logos_class$_ungrouped$MPUNowPlayingController, @selector(init), (IMP)&_logos_method$_ungrouped$MPUNowPlayingController$init, (IMP*)&_logos_orig$_ungrouped$MPUNowPlayingController$init);} else {HBLogError(@"logos: nil class %s", "MPUNowPlayingController");}{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'd'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_metaclass$_ungrouped$MPUNowPlayingController, @selector(_is2_elapsedTime), (IMP)&_logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_elapsedTime, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'd'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_metaclass$_ungrouped$MPUNowPlayingController, @selector(_is2_currentDuration), (IMP)&_logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_currentDuration, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(BOOL), strlen(@encode(BOOL))); i += strlen(@encode(BOOL)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_metaclass$_ungrouped$MPUNowPlayingController, @selector(_is2_currentNowPlayingAppIsRunning), (IMP)&_logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_currentNowPlayingAppIsRunning, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_metaclass$_ungrouped$MPUNowPlayingController, @selector(_is2_nowPlayingAppDisplayID), (IMP)&_logos_meta_method$_ungrouped$MPUNowPlayingController$_is2_nowPlayingAppDisplayID, _typeEncoding); }Class _logos_class$_ungrouped$SBApplication = objc_getClass("SBApplication"); if (_logos_class$_ungrouped$SBApplication) {MSHookMessageEx(_logos_class$_ungrouped$SBApplication, @selector(setBadge:), (IMP)&_logos_method$_ungrouped$SBApplication$setBadge$, (IMP*)&_logos_orig$_ungrouped$SBApplication$setBadge$);} else {HBLogError(@"logos: nil class %s", "SBApplication");}Class _logos_class$_ungrouped$SBApplicationIcon = objc_getClass("SBApplicationIcon"); if (_logos_class$_ungrouped$SBApplicationIcon) {MSHookMessageEx(_logos_class$_ungrouped$SBApplicationIcon, @selector(setBadge:), (IMP)&_logos_method$_ungrouped$SBApplicationIcon$setBadge$, (IMP*)&_logos_orig$_ungrouped$SBApplicationIcon$setBadge$);} else {HBLogError(@"logos: nil class %s", "SBApplicationIcon");}Class _logos_class$_ungrouped$SBAwayBulletinListController = objc_getClass("SBAwayBulletinListController"); if (_logos_class$_ungrouped$SBAwayBulletinListController) {MSHookMessageEx(_logos_class$_ungrouped$SBAwayBulletinListController, @selector(_updateModelAndTableViewForAddition:), (IMP)&_logos_method$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForAddition$, (IMP*)&_logos_orig$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForAddition$);} else {HBLogError(@"logos: nil class %s", "SBAwayBulletinListController");}if (_logos_class$_ungrouped$SBAwayBulletinListController) {MSHookMessageEx(_logos_class$_ungrouped$SBAwayBulletinListController, @selector(_updateModelAndTableViewForModification:originalHeight:), (IMP)&_logos_method$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForModification$originalHeight$, (IMP*)&_logos_orig$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForModification$originalHeight$);} else {HBLogError(@"logos: nil class %s", "SBAwayBulletinListController");}if (_logos_class$_ungrouped$SBAwayBulletinListController) {MSHookMessageEx(_logos_class$_ungrouped$SBAwayBulletinListController, @selector(_updateModelAndTableViewForRemoval:originalHeight:), (IMP)&_logos_method$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForRemoval$originalHeight$, (IMP*)&_logos_orig$_ungrouped$SBAwayBulletinListController$_updateModelAndTableViewForRemoval$originalHeight$);} else {HBLogError(@"logos: nil class %s", "SBAwayBulletinListController");}Class _logos_class$_ungrouped$SBLockScreenNotificationListController = objc_getClass("SBLockScreenNotificationListController"); if (_logos_class$_ungrouped$SBLockScreenNotificationListController) {MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenNotificationListController, @selector(_updateModelAndViewForAdditionOfItem:), (IMP)&_logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForAdditionOfItem$, (IMP*)&_logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForAdditionOfItem$);} else {HBLogError(@"logos: nil class %s", "SBLockScreenNotificationListController");}if (_logos_class$_ungrouped$SBLockScreenNotificationListController) {MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenNotificationListController, @selector(_updateModelAndViewForReplacingItem:withNewItem:), (IMP)&_logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForReplacingItem$withNewItem$, (IMP*)&_logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForReplacingItem$withNewItem$);} else {HBLogError(@"logos: nil class %s", "SBLockScreenNotificationListController");}if (_logos_class$_ungrouped$SBLockScreenNotificationListController) {MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenNotificationListController, @selector(_updateModelAndViewForModificationOfItem:), (IMP)&_logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForModificationOfItem$, (IMP*)&_logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelAndViewForModificationOfItem$);} else {HBLogError(@"logos: nil class %s", "SBLockScreenNotificationListController");}if (_logos_class$_ungrouped$SBLockScreenNotificationListController) {MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenNotificationListController, @selector(_updateModelForRemovalOfItem:updateView:), (IMP)&_logos_method$_ungrouped$SBLockScreenNotificationListController$_updateModelForRemovalOfItem$updateView$, (IMP*)&_logos_orig$_ungrouped$SBLockScreenNotificationListController$_updateModelForRemovalOfItem$updateView$);} else {HBLogError(@"logos: nil class %s", "SBLockScreenNotificationListController");}Class _logos_class$_ungrouped$SBDashBoardViewController = objc_getClass("SBDashBoardViewController"); if (_logos_class$_ungrouped$SBDashBoardViewController) {MSHookMessageEx(_logos_class$_ungrouped$SBDashBoardViewController, @selector(postNotificationRequest:forCoalescedNotification:), (IMP)&_logos_method$_ungrouped$SBDashBoardViewController$postNotificationRequest$forCoalescedNotification$, (IMP*)&_logos_orig$_ungrouped$SBDashBoardViewController$postNotificationRequest$forCoalescedNotification$);} else {HBLogError(@"logos: nil class %s", "SBDashBoardViewController");}if (_logos_class$_ungrouped$SBDashBoardViewController) {MSHookMessageEx(_logos_class$_ungrouped$SBDashBoardViewController, @selector(updateNotificationRequest:forCoalescedNotification:), (IMP)&_logos_method$_ungrouped$SBDashBoardViewController$updateNotificationRequest$forCoalescedNotification$, (IMP*)&_logos_orig$_ungrouped$SBDashBoardViewController$updateNotificationRequest$forCoalescedNotification$);} else {HBLogError(@"logos: nil class %s", "SBDashBoardViewController");}if (_logos_class$_ungrouped$SBDashBoardViewController) {MSHookMessageEx(_logos_class$_ungrouped$SBDashBoardViewController, @selector(withdrawNotificationRequest:forCoalescedNotification:), (IMP)&_logos_method$_ungrouped$SBDashBoardViewController$withdrawNotificationRequest$forCoalescedNotification$, (IMP*)&_logos_orig$_ungrouped$SBDashBoardViewController$withdrawNotificationRequest$forCoalescedNotification$);} else {HBLogError(@"logos: nil class %s", "SBDashBoardViewController");}if (_logos_class$_ungrouped$SBDashBoardViewController) {MSHookMessageEx(_logos_class$_ungrouped$SBDashBoardViewController, @selector(deactivate), (IMP)&_logos_method$_ungrouped$SBDashBoardViewController$deactivate, (IMP*)&_logos_orig$_ungrouped$SBDashBoardViewController$deactivate);} else {HBLogError(@"logos: nil class %s", "SBDashBoardViewController");}if (_logos_class$_ungrouped$SBDashBoardViewController) {MSHookMessageEx(_logos_class$_ungrouped$SBDashBoardViewController, @selector(setInScreenOffMode:forAutoUnlock:), (IMP)&_logos_method$_ungrouped$SBDashBoardViewController$setInScreenOffMode$forAutoUnlock$, (IMP*)&_logos_orig$_ungrouped$SBDashBoardViewController$setInScreenOffMode$forAutoUnlock$);} else {HBLogError(@"logos: nil class %s", "SBDashBoardViewController");}Class _logos_class$_ungrouped$SBLockScreenViewController = objc_getClass("SBLockScreenViewController"); if (_logos_class$_ungrouped$SBLockScreenViewController) {MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewController, @selector(_releaseLockScreenView), (IMP)&_logos_method$_ungrouped$SBLockScreenViewController$_releaseLockScreenView, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewController$_releaseLockScreenView);} else {HBLogError(@"logos: nil class %s", "SBLockScreenViewController");}if (_logos_class$_ungrouped$SBLockScreenViewController) {MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewController, @selector(_handleDisplayTurnedOnWhileUILocked:), (IMP)&_logos_method$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOnWhileUILocked$, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOnWhileUILocked$);} else {HBLogError(@"logos: nil class %s", "SBLockScreenViewController");}if (_logos_class$_ungrouped$SBLockScreenViewController) {MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewController, @selector(_handleDisplayTurnedOn), (IMP)&_logos_method$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOn, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOn);} else {HBLogError(@"logos: nil class %s", "SBLockScreenViewController");}if (_logos_class$_ungrouped$SBLockScreenViewController) {MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewController, @selector(_handleDisplayTurnedOff), (IMP)&_logos_method$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOff, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewController$_handleDisplayTurnedOff);} else {HBLogError(@"logos: nil class %s", "SBLockScreenViewController");}Class _logos_class$_ungrouped$SBAwayController = objc_getClass("SBAwayController"); if (_logos_class$_ungrouped$SBAwayController) {MSHookMessageEx(_logos_class$_ungrouped$SBAwayController, @selector(_releaseAwayView), (IMP)&_logos_method$_ungrouped$SBAwayController$_releaseAwayView, (IMP*)&_logos_orig$_ungrouped$SBAwayController$_releaseAwayView);} else {HBLogError(@"logos: nil class %s", "SBAwayController");}if (_logos_class$_ungrouped$SBAwayController) {MSHookMessageEx(_logos_class$_ungrouped$SBAwayController, @selector(undimScreen), (IMP)&_logos_method$_ungrouped$SBAwayController$undimScreen, (IMP*)&_logos_orig$_ungrouped$SBAwayController$undimScreen);} else {HBLogError(@"logos: nil class %s", "SBAwayController");}if (_logos_class$_ungrouped$SBAwayController) {MSHookMessageEx(_logos_class$_ungrouped$SBAwayController, @selector(undimScreen:), (IMP)&_logos_method$_ungrouped$SBAwayController$undimScreen$, (IMP*)&_logos_orig$_ungrouped$SBAwayController$undimScreen$);} else {HBLogError(@"logos: nil class %s", "SBAwayController");}if (_logos_class$_ungrouped$SBAwayController) {MSHookMessageEx(_logos_class$_ungrouped$SBAwayController, @selector(dimScreen:), (IMP)&_logos_method$_ungrouped$SBAwayController$dimScreen$, (IMP*)&_logos_orig$_ungrouped$SBAwayController$dimScreen$);} else {HBLogError(@"logos: nil class %s", "SBAwayController");}Class _logos_class$_ungrouped$BBServer = objc_getClass("BBServer"); Class _logos_metaclass$_ungrouped$BBServer = object_getClass(_logos_class$_ungrouped$BBServer); { char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_metaclass$_ungrouped$BBServer, @selector(IS2_sharedInstance), (IMP)&_logos_meta_method$_ungrouped$BBServer$IS2_sharedInstance, _typeEncoding); }if (_logos_class$_ungrouped$BBServer) {MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(init), (IMP)&_logos_method$_ungrouped$BBServer$init, (IMP*)&_logos_orig$_ungrouped$BBServer$init);} else {HBLogError(@"logos: nil class %s", "BBServer");}if (_logos_class$_ungrouped$BBServer) {MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(publishBulletin:destinations:alwaysToLockScreen:), (IMP)&_logos_method$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$, (IMP*)&_logos_orig$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$);} else {HBLogError(@"logos: nil class %s", "BBServer");}if (_logos_class$_ungrouped$BBServer) {MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(_sendRemoveBulletins:toFeeds:shouldSync:), (IMP)&_logos_method$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$, (IMP*)&_logos_orig$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$);} else {HBLogError(@"logos: nil class %s", "BBServer");}}
    
    
    dlopen("/usr/lib/libcycript.dylib", RTLD_NOW);
    MSImageRef Cycript(MSGetImageByName("/usr/lib/libcycript.dylib"));
    
    bool (*All_hasProperty_sym)(JSContextRef, JSObjectRef, JSStringRef) = (bool(*)(JSContextRef, JSObjectRef, JSStringRef))MSFindSymbol(Cycript, "__ZL15All_hasPropertyPK15OpaqueJSContextP13OpaqueJSValueP14OpaqueJSString");
    
    JSObjectRef (*CYCastJSObject_sym)(JSContextRef, JSValueRef) = (JSObjectRef(*)(JSContextRef, JSValueRef))MSFindSymbol(Cycript, "__Z14CYCastJSObjectPK15OpaqueJSContextPK13OpaqueJSValue");
    
    JSValueRef (*CYCallAsFunction_sym)(JSContextRef, JSObjectRef, JSObjectRef, size_t, const JSValueRef[]) = (JSValueRef(*)(JSContextRef, JSObjectRef, JSObjectRef, size_t, const JSValueRef[]))MSFindSymbol(Cycript, "__Z16CYCallAsFunctionPK15OpaqueJSContextP13OpaqueJSValueS3_mPKPKS2_");
    
    
    if (All_hasProperty_sym != NULL) {
        MSHookFunction(All_hasProperty_sym, $All_hasProperty, &ori_All_hasProperty);
    }
    
    if (CYCastJSObject_sym != NULL) {
        MSHookFunction(CYCastJSObject_sym, $CYCastJSObject, &ori_CYCastJSObject);
    }
    
    
    if (CYCallAsFunction_sym != NULL) {
        MSHookFunction(CYCallAsFunction_sym, $CYCallAsFunction, &ori_CYCallAsFunction);
    }
    
    [IS2Private setupForTweakLoaded];
}
