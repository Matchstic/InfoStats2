#import <objc/runtime.h>
#include "WebCycript.h"
#import <UIKit/UIKit.h>

@class WebScriptObject;

@interface UIWebDocumentView : UIView
-(WebView*)webView;
@end

@interface WebFrame : NSObject
-(id)dataSource;
@end

@interface WebView : NSObject
-(void)setPreferencesIdentifier:(id)arg1;
-(void)_setAllowsMessaging:(BOOL)arg1;
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
@end

@interface IS2Media : NSObject
+(void)nowPlayingDataDidUpdate;
@end

@interface IS2Notifications : NSObject
+(void)updateNCCountWithIdentifier:(NSString*)identifier andValue:(int)value;
+(void)updateBadgeCountWithIdentifier:(NSString*)identifier andValue:(int)value;
+(int)notificationCountForApplication:(NSString*)bundleIdentifier;
@end

@interface SBApplication : NSObject
- (id)bundleIdentifier;
- (id)badgeNumberOrString;
@end

@interface SBApplicationIcon : NSObject
-(id)badgeNumberOrString;
-(SBApplication*)application;
@end

@interface BBBulletin : NSObject
@property(copy) NSString * sectionID;
@end

@interface BBServer : NSObject
- (id)allBulletinIDsForSectionID:(id)arg1;
@end

@interface IWWidget : UIView {
    UIWebView *_webView;
}
- (void)webView:(id)arg1 didClearWindowObject:(id)arg2 forFrame:(id)arg3;
@end

#pragma mark Begin actual code

#pragma mark Injection of Cycript into WebViews

// Supports LockHTML, and anything else hopefully
// XenHTML will defer to this tweak for injecting into UIWebView and WKWebView as appropriate
// GroovyLock is supported by itself, just needs the hooks from WebCycript to function
// Convergance is the same as GroovyLock

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

-(void)webView:(WebView *)view addMessageToConsole:(NSDictionary *)message {
    NSLog(@"addMessageToConsole: %@", message);
    
    if ([UIWebView instancesRespondToSelector:@selector(webView:addMessageToConsole:)])
        %orig;
}

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
            NSLog(@"*** Cycript was injected into an instance of %@", [self class]);
        } @catch (NSException *e) {
            NSLog(@"*** CydgetSetupContext => %@", e);
        }
    }
    
    %orig;
}

%end

// Needed to inject into iWidgets

%hook IWWidget

- (void)webView:(id)arg1 didClearWindowObject:(id)arg2 forFrame:(id)arg3 {
    UIWebView *webView = MSHookIvar<UIWebView*>(self, "_webView");
    [webView webView:arg1 didClearWindowObject:arg2 forFrame:arg3];
    
    %orig;
}

%end

#pragma mark Hooks needed for data access

// Finished loading notifier

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;
    [IS2Private setupAfterSpringBoardLoaded];
}

%end

// Media

%hook SBMediaController

-(void)_nowPlayingInfoChanged {
    %orig;
    
    [IS2Media nowPlayingDataDidUpdate];
}

%end

// Notifications

%hook SBApplication

// iOS 7.0 onwards
-(void)setBadge:(id)arg1 {
    %orig;
    
    int badgeCount = 0;
    
    if ([self respondsToSelector:@selector(badgeNumberOrString)])
        badgeCount = [[self badgeNumberOrString] intValue];
        
    NSString *ident = [self bundleIdentifier];
    [IS2Notifications updateBadgeCountWithIdentifier:ident andValue:badgeCount];
    
    NSLog(@"*** [InfoStats2 | Notifications] :: Updated for %@ with new count of %d", ident, badgeCount);
}

%end

%hook SBApplicationIcon

// iOS 6 support
-(void)setBadge:(id)arg1 {
    %orig;
    
    int badgeCount = 0;
    
    if ([self respondsToSelector:@selector(badgeNumberOrString)])
        badgeCount = [[self badgeNumberOrString] intValue];
        
    NSString *ident = [[self application] bundleIdentifier];
    [IS2Notifications updateBadgeCountWithIdentifier:ident andValue:badgeCount];
    
    NSLog(@"*** [InfoStats2 | Notifications] :: Updated for %@ with new count of %d", ident, badgeCount);
}

%end

static BBServer *sharedServer;

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

#pragma mark Constructor

%ctor {
    // Load up iWidgets dylib to hook it
    dlopen("/Library/MobileSubstrate/DynamicLibraries/iWidgets.dylib", RTLD_NOW);
    
    %init;
    
    [IS2Private setupForTweakLoaded];
}