#line 1 "/Users/Matt/iOS/Projects/InfoStats2/InfoStats2/InfoStats2.xm"
#import <objc/runtime.h>
#include "WebCycript.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebView.h>
#import <WebKit/WebPreferences.h>
#import <WebKit/WebFrame.h>

@class WebScriptObject;

@interface UIWebDocumentView : UIView
-(WebView*)webView;
@end

@interface UIWebView (Apple)
- (void)webView:(WebView *)view addMessageToConsole:(NSDictionary *)message;
- (void)webView:(WebView *)webview didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame;
-(UIWebDocumentView*)_documentView;
@end

@protocol IS2Delegate <NSObject>
- (void)webView:(WebView *)webview didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame;
@end

@interface IS2Media : NSObject
+(void)nowPlayingDataDidUpdate;
@end

@interface IWWidget : UIView {
    UIWebView *_webView;
}
- (void)webView:(id)arg1 didClearWindowObject:(id)arg2 forFrame:(id)arg3;
@end

#pragma mark Begin actual code



#include <logos/logos.h>
#include <substrate.h>
@class SBMediaController; @class UIWebView; @class IWWidget; 
static void (*_logos_orig$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$)(IWWidget*, SEL, id, id, id); static void _logos_method$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$(IWWidget*, SEL, id, id, id); static id (*_logos_orig$_ungrouped$UIWebView$initWithFrame$)(UIWebView*, SEL, CGRect); static id _logos_method$_ungrouped$UIWebView$initWithFrame$(UIWebView*, SEL, CGRect); static void (*_logos_orig$_ungrouped$UIWebView$webView$addMessageToConsole$)(UIWebView*, SEL, WebView *, NSDictionary *); static void _logos_method$_ungrouped$UIWebView$webView$addMessageToConsole$(UIWebView*, SEL, WebView *, NSDictionary *); static void (*_logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$)(UIWebView*, SEL, WebView *, WebScriptObject *, WebFrame *); static void _logos_method$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$(UIWebView*, SEL, WebView *, WebScriptObject *, WebFrame *); static void (*_logos_orig$_ungrouped$SBMediaController$_nowPlayingInfoChanged)(SBMediaController*, SEL); static void _logos_method$_ungrouped$SBMediaController$_nowPlayingInfoChanged(SBMediaController*, SEL); 

#line 38 "/Users/Matt/iOS/Projects/InfoStats2/InfoStats2/InfoStats2.xm"


static void _logos_method$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$(IWWidget* self, SEL _cmd, id arg1, id arg2, id arg3) {
    UIWebView *webView = MSHookIvar<UIWebView*>(self, "_webView");
    [webView webView:arg1 didClearWindowObject:arg2 forFrame:arg3];
    
    _logos_orig$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$(self, _cmd, arg1, arg2, arg3);
}



#pragma mark Injection of Cycript into WebViews



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
    if ([[self class] isEqual:[objc_getClass("CydgetWebView") class]]) {
        
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





static void _logos_method$_ungrouped$SBMediaController$_nowPlayingInfoChanged(SBMediaController* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBMediaController$_nowPlayingInfoChanged(self, _cmd);
    
    [IS2Media nowPlayingDataDidUpdate];
}



static __attribute__((constructor)) void _logosLocalCtor_f67a23ac() {
    
    dlopen("/Library/MobileSubstrate/DynamicLibraries/iWidgets.dylib", RTLD_NOW);
    
    
    
    {Class _logos_class$_ungrouped$IWWidget = objc_getClass("IWWidget"); MSHookMessageEx(_logos_class$_ungrouped$IWWidget, @selector(webView:didClearWindowObject:forFrame:), (IMP)&_logos_method$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$, (IMP*)&_logos_orig$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$);Class _logos_class$_ungrouped$UIWebView = objc_getClass("UIWebView"); MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(initWithFrame:), (IMP)&_logos_method$_ungrouped$UIWebView$initWithFrame$, (IMP*)&_logos_orig$_ungrouped$UIWebView$initWithFrame$);MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(webView:addMessageToConsole:), (IMP)&_logos_method$_ungrouped$UIWebView$webView$addMessageToConsole$, (IMP*)&_logos_orig$_ungrouped$UIWebView$webView$addMessageToConsole$);MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(webView:didClearWindowObject:forFrame:), (IMP)&_logos_method$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$, (IMP*)&_logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$);Class _logos_class$_ungrouped$SBMediaController = objc_getClass("SBMediaController"); MSHookMessageEx(_logos_class$_ungrouped$SBMediaController, @selector(_nowPlayingInfoChanged), (IMP)&_logos_method$_ungrouped$SBMediaController$_nowPlayingInfoChanged, (IMP*)&_logos_orig$_ungrouped$SBMediaController$_nowPlayingInfoChanged);}
}
