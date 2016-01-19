#line 1 "/Users/Matt/iOS/Projects/InfoStats2/InfoStats2/InfoStats2.xm"
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






#include <logos/logos.h>
#include <substrate.h>
@class UIWebView; @class BBServer; @class SpringBoard; @class SBMediaController; @class SBApplicationIcon; @class IWWidget; @class SBApplication; 
static id (*_logos_orig$_ungrouped$UIWebView$initWithFrame$)(UIWebView*, SEL, CGRect); static id _logos_method$_ungrouped$UIWebView$initWithFrame$(UIWebView*, SEL, CGRect); static void (*_logos_orig$_ungrouped$UIWebView$webView$addMessageToConsole$)(UIWebView*, SEL, WebView *, NSDictionary *); static void _logos_method$_ungrouped$UIWebView$webView$addMessageToConsole$(UIWebView*, SEL, WebView *, NSDictionary *); static void (*_logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$)(UIWebView*, SEL, WebView *, WebScriptObject *, WebFrame *); static void _logos_method$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$(UIWebView*, SEL, WebView *, WebScriptObject *, WebFrame *); static void (*_logos_orig$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$)(IWWidget*, SEL, id, id, id); static void _logos_method$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$(IWWidget*, SEL, id, id, id); static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(SpringBoard*, SEL, id); static void (*_logos_orig$_ungrouped$SBMediaController$_nowPlayingInfoChanged)(SBMediaController*, SEL); static void _logos_method$_ungrouped$SBMediaController$_nowPlayingInfoChanged(SBMediaController*, SEL); static void (*_logos_orig$_ungrouped$SBApplication$setBadge$)(SBApplication*, SEL, id); static void _logos_method$_ungrouped$SBApplication$setBadge$(SBApplication*, SEL, id); static void (*_logos_orig$_ungrouped$SBApplicationIcon$setBadge$)(SBApplicationIcon*, SEL, id); static void _logos_method$_ungrouped$SBApplicationIcon$setBadge$(SBApplicationIcon*, SEL, id); static id _logos_meta_method$_ungrouped$BBServer$IS2_sharedInstance(Class, SEL); static id (*_logos_orig$_ungrouped$BBServer$init)(BBServer*, SEL); static id _logos_method$_ungrouped$BBServer$init(BBServer*, SEL); static void (*_logos_orig$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$)(BBServer*, SEL, __unsafe_unretained BBBulletin*, unsigned long long, _Bool); static void _logos_method$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$(BBServer*, SEL, __unsafe_unretained BBBulletin*, unsigned long long, _Bool); static void (*_logos_orig$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$)(BBServer*, SEL, __unsafe_unretained NSSet*, unsigned long long, _Bool); static void _logos_method$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$(BBServer*, SEL, __unsafe_unretained NSSet*, unsigned long long, _Bool); 

#line 78 "/Users/Matt/iOS/Projects/InfoStats2/InfoStats2/InfoStats2.xm"


static id _logos_method$_ungrouped$UIWebView$initWithFrame$(UIWebView* self, SEL _cmd, CGRect frame) {
    UIWebView *original = _logos_orig$_ungrouped$UIWebView$initWithFrame$(self, _cmd, frame);
        
    UIWebDocumentView *document = [original _documentView];
    WebView *webview = [document webView];
        
    [webview setPreferencesIdentifier:@"WebCycript"];
        
    if ([webview respondsToSelector:@selector(_setAllowsMessaging:)])
        [webview _setAllowsMessaging:YES];
    
    
    
    
    return original;
}

static void _logos_method$_ungrouped$UIWebView$webView$addMessageToConsole$(UIWebView* self, SEL _cmd, WebView * view, NSDictionary * message) {
    NSLog(@"addMessageToConsole: %@", message);
    
    if ([UIWebView instancesRespondToSelector:@selector(webView:addMessageToConsole:)])
        _logos_orig$_ungrouped$UIWebView$webView$addMessageToConsole$(self, _cmd, view, message);
}

static void _logos_method$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$(UIWebView* self, SEL _cmd, WebView * webview, WebScriptObject * window, WebFrame * frame) {
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
            NSLog(@"*** Cycript was injected into an instance of %@", [self class]);
        } @catch (NSException *e) {
            NSLog(@"*** CydgetSetupContext => %@", e);
        }
    }
    
    _logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$(self, _cmd, webview, window, frame);
}







static void _logos_method$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$(IWWidget* self, SEL _cmd, id arg1, id arg2, id arg3) {
    UIWebView *webView = MSHookIvar<UIWebView*>(self, "_webView");
    [webView webView:arg1 didClearWindowObject:arg2 forFrame:arg3];
    
    _logos_orig$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$(self, _cmd, arg1, arg2, arg3);
}



#pragma mark Hooks needed for data access





static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(SpringBoard* self, SEL _cmd, id application) {
    _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);
    [IS2Private setupAfterSpringBoardLoaded];
}







static void _logos_method$_ungrouped$SBMediaController$_nowPlayingInfoChanged(SBMediaController* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBMediaController$_nowPlayingInfoChanged(self, _cmd);
    
    [IS2Media nowPlayingDataDidUpdate];
}








static void _logos_method$_ungrouped$SBApplication$setBadge$(SBApplication* self, SEL _cmd, id arg1) {
    _logos_orig$_ungrouped$SBApplication$setBadge$(self, _cmd, arg1);
    
    int badgeCount = 0;
    
    if ([self respondsToSelector:@selector(badgeNumberOrString)])
        badgeCount = [[self badgeNumberOrString] intValue];
        
    NSString *ident = [self bundleIdentifier];
    [IS2Notifications updateBadgeCountWithIdentifier:ident andValue:badgeCount];
    
    NSLog(@"*** [InfoStats2 | Notifications] :: Updated for %@ with new count of %d", ident, badgeCount);
}






static void _logos_method$_ungrouped$SBApplicationIcon$setBadge$(SBApplicationIcon* self, SEL _cmd, id arg1) {
    _logos_orig$_ungrouped$SBApplicationIcon$setBadge$(self, _cmd, arg1);
    
    int badgeCount = 0;
    
    if ([self respondsToSelector:@selector(badgeNumberOrString)])
        badgeCount = [[self badgeNumberOrString] intValue];
        
    NSString *ident = [[self application] bundleIdentifier];
    [IS2Notifications updateBadgeCountWithIdentifier:ident andValue:badgeCount];
    
    NSLog(@"*** [InfoStats2 | Notifications] :: Updated for %@ with new count of %d", ident, badgeCount);
}



static BBServer *sharedServer;




static id _logos_meta_method$_ungrouped$BBServer$IS2_sharedInstance(Class self, SEL _cmd) {
    return sharedServer;
}

static id _logos_method$_ungrouped$BBServer$init(BBServer* self, SEL _cmd) {
    sharedServer = _logos_orig$_ungrouped$BBServer$init(self, _cmd);
    return sharedServer;
}

static void _logos_method$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$(BBServer* self, SEL _cmd, __unsafe_unretained BBBulletin* arg1, unsigned long long arg2, _Bool arg3) {
    _logos_orig$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$(self, _cmd, arg1, arg2, arg3);
    
    NSArray *bulletins = [self allBulletinIDsForSectionID:arg1.sectionID];
    int count = (int)bulletins.count;
    [IS2Notifications updateNCCountWithIdentifier:[arg1.sectionID copy] andValue:count];
}

static void _logos_method$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$(BBServer* self, SEL _cmd, __unsafe_unretained NSSet* arg1, unsigned long long arg2, _Bool arg3) {
    _logos_orig$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$(self, _cmd, arg1, arg2, arg3);
    
    BBBulletin *bulletin = [arg1 anyObject];
    if (!bulletin)
        return;
    
    NSString *section = bulletin.sectionID;
    [IS2Notifications updateNCCountWithIdentifier:section andValue:[IS2Notifications notificationCountForApplication:section] - (int)arg1.count];
}



#pragma mark Constructor

static __attribute__((constructor)) void _logosLocalCtor_a63c6e76() {
    
    dlopen("/Library/MobileSubstrate/DynamicLibraries/iWidgets.dylib", RTLD_NOW);
    
    {Class _logos_class$_ungrouped$UIWebView = objc_getClass("UIWebView"); MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(initWithFrame:), (IMP)&_logos_method$_ungrouped$UIWebView$initWithFrame$, (IMP*)&_logos_orig$_ungrouped$UIWebView$initWithFrame$);MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(webView:addMessageToConsole:), (IMP)&_logos_method$_ungrouped$UIWebView$webView$addMessageToConsole$, (IMP*)&_logos_orig$_ungrouped$UIWebView$webView$addMessageToConsole$);MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(webView:didClearWindowObject:forFrame:), (IMP)&_logos_method$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$, (IMP*)&_logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$);Class _logos_class$_ungrouped$IWWidget = objc_getClass("IWWidget"); MSHookMessageEx(_logos_class$_ungrouped$IWWidget, @selector(webView:didClearWindowObject:forFrame:), (IMP)&_logos_method$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$, (IMP*)&_logos_orig$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$);Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);Class _logos_class$_ungrouped$SBMediaController = objc_getClass("SBMediaController"); MSHookMessageEx(_logos_class$_ungrouped$SBMediaController, @selector(_nowPlayingInfoChanged), (IMP)&_logos_method$_ungrouped$SBMediaController$_nowPlayingInfoChanged, (IMP*)&_logos_orig$_ungrouped$SBMediaController$_nowPlayingInfoChanged);Class _logos_class$_ungrouped$SBApplication = objc_getClass("SBApplication"); MSHookMessageEx(_logos_class$_ungrouped$SBApplication, @selector(setBadge:), (IMP)&_logos_method$_ungrouped$SBApplication$setBadge$, (IMP*)&_logos_orig$_ungrouped$SBApplication$setBadge$);Class _logos_class$_ungrouped$SBApplicationIcon = objc_getClass("SBApplicationIcon"); MSHookMessageEx(_logos_class$_ungrouped$SBApplicationIcon, @selector(setBadge:), (IMP)&_logos_method$_ungrouped$SBApplicationIcon$setBadge$, (IMP*)&_logos_orig$_ungrouped$SBApplicationIcon$setBadge$);Class _logos_class$_ungrouped$BBServer = objc_getClass("BBServer"); Class _logos_metaclass$_ungrouped$BBServer = object_getClass(_logos_class$_ungrouped$BBServer); { char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_metaclass$_ungrouped$BBServer, @selector(IS2_sharedInstance), (IMP)&_logos_meta_method$_ungrouped$BBServer$IS2_sharedInstance, _typeEncoding); }MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(init), (IMP)&_logos_method$_ungrouped$BBServer$init, (IMP*)&_logos_orig$_ungrouped$BBServer$init);MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(publishBulletin:destinations:alwaysToLockScreen:), (IMP)&_logos_method$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$, (IMP*)&_logos_orig$_ungrouped$BBServer$publishBulletin$destinations$alwaysToLockScreen$);MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(_sendRemoveBulletins:toFeeds:shouldSync:), (IMP)&_logos_method$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$, (IMP*)&_logos_orig$_ungrouped$BBServer$_sendRemoveBulletins$toFeeds$shouldSync$);}
    
    [IS2Private setupForTweakLoaded];
}
