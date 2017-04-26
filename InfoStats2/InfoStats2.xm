#import <objc/runtime.h>
#include "WebCycript.h"
#import <UIKit/UIKit.h>
#include <typeinfo> // for bad_cast
#include <JavaScriptCore/JSContextRef.h> // For libcycript hooks
#include <JavaScriptCore/JSObjectRef.h> // For libcycript hooks

////////////////////////////////////////////////////////////////////////////////
// Function definitions

// XXX: In an ideal world, these should be in a seperate file for readability and to avoid duplication.
// However, in an ideal world, I'm not lazy.

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

////////////////////////////////////////////////////////////////////////////////
// Begin actual code

static void showAlert(NSString *message) {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"IS2"
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}

#pragma mark Injection of Cycript into WebViews

// Supports LockHTML, and anything else hopefully
// Xen HTML will defer to this tweak for injecting into UIWebView and WKWebView as appropriate
// GroovyLock is supported by itself, just needs the hooks from WebCycript to function
// Convergance is the same as GroovyLock
// Cydget is handled again the same way

/*
 * Apple also provides WKWebView, which is a far better way of doing web stuff than UIWebView.
 * However, the issue with that and Cycript is that WkWebView actually runs the webview in another process,
 * and as such, we can't easily provide InfoStats 2 and Cycript injection into that.
 *
 * Perhaps a good solution to this will be to "bridge" the classes in the web process to SrpingBoard, and 
 * inject Cycript somehow in the webprocess. This has the unfortunate side effect of C functions from 
 * SprngBoard or a framework not loaded into the webprocess failing horribly.
 */

%hook UIWebView

-(id)initWithFrame:(CGRect)frame {
    UIWebView *original = %orig;
        
    UIWebDocumentView *document = [original _documentView];
    WebView *webview = [document webView];
        
    [webview setPreferencesIdentifier:@"WebCycript"];
        
    if ([webview respondsToSelector:@selector(_setAllowsMessaging:)])
        [webview _setAllowsMessaging:YES];
    
    // TODO: We may need to prevent other tweaks messing with the frame delegate of WebView
    // since that prevents Cycript from being injected.
    
    return original;
}

// Remind me again why this is needed?
-(void)webView:(WebView *)view addMessageToConsole:(NSDictionary *)message {
    NSLog(@"[InfoStats2] :: addMessageToConsole: %@", message);
    
    if ([UIWebView instancesRespondToSelector:@selector(webView:addMessageToConsole:)])
        %orig;
}

// Utilise the WebFrameLoadDelegate to do our magic.
- (void)webView:(WebView *)webview didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame {
    
    
    if ([[self class] isEqual:[objc_getClass("CydgetWebView") class]] ||
        [[self class] isEqual:[objc_getClass("GLWebView") class]] ||
        [[self class] isEqual:[objc_getClass("CVLockHTMLBackgroundView") class]]) {
        // No need to inject Cycript into tweaks that already provide support for it.
        %orig;
        return;
    }
    
    NSString *href = [[[[frame dataSource] request] URL] absoluteString];
    if (href) {
        // Inject Cycript into this webview.
        @try {
            WebCycriptSetupView(webview);
            NSLog(@"[InfoStats2] :: Cycript was injected into an instance of %@", [self class]);
        } @catch (NSException *e) {
            NSLog(@"[InfoStats2] :: Exception in Cycript injection => %@", e);
        }
    }
    
    %orig;
}

%end

#pragma mark Needed to inject into iWidgets

%hook IWWidget

- (void)webView:(id)arg1 didClearWindowObject:(id)arg2 forFrame:(id)arg3 {
    UIWebView *webView = MSHookIvar<UIWebView*>(self, "_webView");
    [webView webView:arg1 didClearWindowObject:arg2 forFrame:arg3];
    
    %orig;
}

%end

// Hacky fix for iOS 6 iWidgets (Can't believe this is necessary)

%hook UIView

%new
-(id)_newCloseBoxOfType:(int)type {
    return nil;
}

%end

#pragma mark Hooks needed for data access

#pragma mark Finished loading notifier

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;
    
    [IS2Private setupAfterSpringBoardLoaded];
}

%end

#pragma mark Media

// TODO: Leaving present since we haven't tested the non-requirement of this yet.
/*%hook SBMediaController

// Only needed for iOS 6 to update when media data changes.
-(void)_nowPlayingInfoChanged {
    %orig;
    
    if ([[UIDevice currentDevice] systemVersion].floatValue < 7.0) {
        [IS2Media nowPlayingDataDidUpdate];
    }
}

%end*/

static MPUNowPlayingController * __weak globalMPUNowPlaying;

%hook MPUNowPlayingController
// iOS 7 and onwards should use this, works nicer.

- (id)init {
    id orig = %orig;
    
    globalMPUNowPlaying = orig;
    
    return orig;
}

%new
+(double)_is2_elapsedTime {
    return [globalMPUNowPlaying currentElapsed];
}

%new
+(double)_is2_currentDuration {
    return [globalMPUNowPlaying currentElapsed];
}

%new
+(BOOL)_is2_currentNowPlayingAppIsRunning {
    return [globalMPUNowPlaying currentNowPlayingAppIsRunning];
}

%new
+(id)_is2_nowPlayingAppDisplayID {
    return [globalMPUNowPlaying nowPlayingAppDisplayID];
}

%end

#pragma mark Notifications

%hook SBApplication

// iOS 7.0 onwards
-(void)setBadge:(id)arg1 {
    %orig;
    
    int badgeCount = 0;
    
    if ([self respondsToSelector:@selector(badgeNumberOrString)])
        badgeCount = [[self badgeNumberOrString] intValue];
        
    NSString *ident = [self bundleIdentifier];
    [IS2Notifications updateBadgeCountWithIdentifier:ident andValue:badgeCount];
    
    //NSLog(@"*** [InfoStats2 | Notifications] :: Updated for %@ with new count of %d", ident, badgeCount);
}

%end

%hook SBApplicationIcon

// iOS 6 support
-(void)setBadge:(id)arg1 {
    %orig;
    
    if ([[UIDevice currentDevice] systemVersion].floatValue < 7.0) {
        int badgeCount = 0;
    
        if ([self respondsToSelector:@selector(badgeNumberOrString)])
            badgeCount = [[self badgeNumberOrString] intValue];
        
        NSString *ident = [[self application] bundleIdentifier];
        [IS2Notifications updateBadgeCountWithIdentifier:ident andValue:badgeCount];
    
        //NSLog(@"*** [InfoStats2 | Notifications] :: Updated for %@ with new count of %d", ident, badgeCount);
    }
}

%end

// Lockscreen hooks

%hook SBAwayBulletinListController // iOS 6

-(void)_updateModelAndTableViewForAddition:(SBAwayBulletinListItem *)listItem {
    if ([[listItem class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:listItem.activeBulletin isRemoval:NO isModification:NO];
    }
    %orig;
}

- (void)_updateModelAndTableViewForModification:(SBAwayBulletinListItem *)arg1 originalHeight:(float)arg2 {
    if ([[arg1 class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:arg1.activeBulletin isRemoval:NO isModification:YES];
    }
    %orig;
}

-(void)_updateModelAndTableViewForRemoval:(SBAwayBulletinListItem *)arg1 originalHeight:(float)arg2 {
    if ([[arg1 class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:arg1.activeBulletin isRemoval:YES isModification:NO];
    }
    %orig;
}

%end

%hook SBLockScreenNotificationListController // iOS 7-9

-(void)_updateModelAndViewForAdditionOfItem:(SBAwayBulletinListItem *)listItem {
    // Update IS2Notifications
    if ([[listItem class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:listItem.activeBulletin isRemoval:NO isModification:NO];
    }
    
    %orig;
}

- (void)_updateModelAndViewForReplacingItem:(SBAwayBulletinListItem *)arg1 withNewItem:(SBAwayBulletinListItem *)arg2 {
    if ([[arg2 class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:arg2.activeBulletin isRemoval:NO isModification:YES];
    }
    
    %orig;
}

- (void)_updateModelAndViewForModificationOfItem:(SBAwayBulletinListItem *)arg1 {
    if ([[arg1 class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:arg1.activeBulletin isRemoval:NO isModification:YES];
    }
    %orig;
}

-(void)_updateModelForRemovalOfItem:(SBAwayBulletinListItem *)arg1 updateView:(BOOL)arg2 {
    if ([[arg1 class] isEqual:[objc_getClass("SBAwayBulletinListItem") class]]) {
        [IS2Notifications updateLockscreenCountWithBulletin:arg1.activeBulletin isRemoval:YES isModification:NO];
    }
    %orig;
}

%end

%hook SBDashBoardViewController // iOS 10+

- (void)postNotificationRequest:(NCNotificationRequest*)arg1 forCoalescedNotification:(id)arg2 {
    [IS2Notifications updateLockscreenCountWithBulletin:arg1.bulletin isRemoval:NO isModification:NO];
    %orig;
}

- (void)updateNotificationRequest:(NCNotificationRequest*)arg1 forCoalescedNotification:(id)arg2 {
    [IS2Notifications updateLockscreenCountWithBulletin:arg1.bulletin isRemoval:NO isModification:YES];
    %orig;
}

- (void)withdrawNotificationRequest:(NCNotificationRequest*)arg1 forCoalescedNotification:(id)arg2 {
    [IS2Notifications updateLockscreenCountWithBulletin:arg1.bulletin isRemoval:YES isModification:NO];
    %orig;
}

%end

#pragma mark Notify that unlocking has occured

%hook SBLockScreenViewController

-(void)_releaseLockScreenView {
    %orig;
    [IS2Notifications removeLockscreenCountsForUnlock];
}

%end

%hook SBAwayController

- (void)_releaseAwayView {
    %orig;
    [IS2Notifications removeLockscreenCountsForUnlock];
}

%end

%hook SBDashBoardViewController

- (void)deactivate {
    %orig;
    [IS2Notifications removeLockscreenCountsForUnlock];
}

%end

static BBServer *sharedServer;

/*
 * We turn BBServer into a "semi-singleton" to be able to access it easier.
 */

%hook BBServer

%new
+(id)IS2_sharedInstance {
    return sharedServer;
}

-(id)init {
    sharedServer = %orig;
    return sharedServer;
}

-(void)publishBulletin:(__unsafe_unretained BBBulletin*)arg1 destinations:(unsigned long long)arg2 alwaysToLockScreen:(_Bool)arg3 {
    %orig;
    
    NSArray *bulletins = [self allBulletinIDsForSectionID:arg1.sectionID];
    int count = (int)bulletins.count;
    [IS2Notifications updateNCCountWithIdentifier:[arg1.sectionID copy] andValue:count];
}

-(void)_sendRemoveBulletins:(__unsafe_unretained NSSet*)arg1 toFeeds:(unsigned long long)arg2 shouldSync:(_Bool)arg3 {
    %orig;
    
    BBBulletin *bulletin = [arg1 anyObject];
    if (!bulletin)
        return;
    
    NSString *section = bulletin.sectionID;
    [IS2Notifications updateNCCountWithIdentifier:section andValue:[IS2Notifications notificationCountForApplication:section] - (int)arg1.count];
}

%end

#pragma mark Display status

// iOS 10+
%hook SBLockScreenManager

- (void)_handleBacklightLevelChanged:(NSNotification*)arg1 {
    %orig;
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        NSDictionary *userInfo = arg1.userInfo;
        
        CGFloat newBacklight = [[userInfo objectForKey:@"SBBacklightNewFactorKey"] floatValue];
        CGFloat oldBacklight = [[userInfo objectForKey:@"SBBacklightOldFactorKey"] floatValue];
        
        if (newBacklight == 0.0) {
            [[IS2Private sharedInstance] setScreenOffState:YES];
        } else if (oldBacklight == 0.0 && newBacklight > 0.0) {
            [[IS2Private sharedInstance] setScreenOffState:NO];
        }
    }
}

%end

// iOS 7-9
%hook SBLockScreenViewController

- (void)_handleDisplayTurnedOnWhileUILocked:(id)locked {
    [[IS2Private sharedInstance] setScreenOffState:NO];
    
    %orig;
}

-(void)_handleDisplayTurnedOn {
    [[IS2Private sharedInstance] setScreenOffState:NO];
    
    %orig;
}

-(void)_handleDisplayTurnedOff {
    %orig;
    
    [[IS2Private sharedInstance] setScreenOffState:YES];
}

%end

// iOS 6
%hook SBAwayController

- (void)undimScreen {
    [[IS2Private sharedInstance] setScreenOffState:NO];
    
    %orig;
}

- (void)undimScreen:(BOOL)arg1 {
    [[IS2Private sharedInstance] setScreenOffState:NO];
    
    %orig;
}

- (void)dimScreen:(BOOL)arg1 {
    %orig;
    
    [[IS2Private sharedInstance] setScreenOffState:YES];
}

%end

#pragma mark Hooks into libcycript ( :( )

/*
 * Here, we add further error checking to Cycript's functions to ensure better stability.
 *
 * Of course, this won't catch everything, only exceptions.
 */

// First up, crash on bad_cast in All_hasProperty (http://gitweb.saurik.com/cycript.git/blob/HEAD:/Execute.cpp#l1399)
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

// Another bad_cast may occur here.
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
        
        // Load up CYJSNull.
        JSValueRef (*CYJSNull)(JSContextRef) = (JSValueRef(*)(JSContextRef))MSFindSymbol(NULL, "__Z8CYJSNullPK15OpaqueJSContext");
        
        return CYJSNull(context);
    }
    
    try {
        return ori_CYCallAsFunction(context, function, _this, count, arguments);
    } catch (std::bad_cast& bc) {
        NSLog(@"*** [InfoStats2 | Warning] :: Caught bad_cast in CYCallAsFunction");
        
        // Load up CYJSNull.
        JSValueRef (*CYJSNull)(JSContextRef) = (JSValueRef(*)(JSContextRef))MSFindSymbol(NULL, "__Z8CYJSNullPK15OpaqueJSContext");
        
        return CYJSNull(context);
    } catch (...) {
        NSLog(@"*** [InfoStats2 | Warning] :: Caught unknown exception in CYCallAsFunction");
        
        // Load up CYJSNull.
        JSValueRef (*CYJSNull)(JSContextRef) = (JSValueRef(*)(JSContextRef))MSFindSymbol(NULL, "__Z8CYJSNullPK15OpaqueJSContext");
        
        return CYJSNull(context);
    }
}

#pragma mark Constructor

%ctor {
    // Load up iWidgets dylib to hook it
    dlopen("/Library/MobileSubstrate/DynamicLibraries/iWidgets.dylib", RTLD_NOW);
    
    %init;
    
    // Load up Cycript's binary image so we can hook into it
    dlopen("/usr/lib/libcycript.dylib", RTLD_NOW);
    MSImageRef Cycript(MSGetImageByName("/usr/lib/libcycript.dylib"));
    
    bool (*All_hasProperty_sym)(JSContextRef, JSObjectRef, JSStringRef) = (bool(*)(JSContextRef, JSObjectRef, JSStringRef))MSFindSymbol(Cycript, "__ZL15All_hasPropertyPK15OpaqueJSContextP13OpaqueJSValueP14OpaqueJSString");
    
    JSObjectRef (*CYCastJSObject_sym)(JSContextRef, JSValueRef) = (JSObjectRef(*)(JSContextRef, JSValueRef))MSFindSymbol(Cycript, "__Z14CYCastJSObjectPK15OpaqueJSContextPK13OpaqueJSValue");
    
    JSValueRef (*CYCallAsFunction_sym)(JSContextRef, JSObjectRef, JSObjectRef, size_t, const JSValueRef[]) = (JSValueRef(*)(JSContextRef, JSObjectRef, JSObjectRef, size_t, const JSValueRef[]))MSFindSymbol(Cycript, "__Z16CYCallAsFunctionPK15OpaqueJSContextP13OpaqueJSValueS3_mPKPKS2_");
    
    // Load hooks into libcycript.
    if (All_hasProperty_sym != NULL) {
        MSHookFunction(All_hasProperty_sym, $All_hasProperty, &ori_All_hasProperty);
    }
    
    if (CYCastJSObject_sym != NULL) {
        MSHookFunction(CYCastJSObject_sym, $CYCastJSObject, &ori_CYCastJSObject);
    }
    
    
    if (CYCallAsFunction_sym != NULL) {
        MSHookFunction(CYCallAsFunction_sym, $CYCallAsFunction, &ori_CYCallAsFunction);
    }
    // And finally, setup the API for whatever can load *before* applicationDidFinishLaunching:
    [IS2Private setupForTweakLoaded];
}
