#line 1 "/Users/Matt/iOS/Projects/InfoStats2/InfoStats2/InfoStats2.xm"
#import <objc/runtime.h>
#import "IS2WebView.h"
#include "WebCycript.h"

@interface IS2Extensions : NSObject
+(void)initializeExtensions;
@end

@interface IWWidget : UIView {
    UIWebView *_webView;
}
- (void)webView:(id)arg1 didClearWindowObject:(id)arg2 forFrame:(id)arg3;
@end



#include <logos/logos.h>
#include <substrate.h>
@class IWWidget; @class UIWebView; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$)(IWWidget*, SEL, id, id, id); static void _logos_method$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$(IWWidget*, SEL, id, id, id); static id (*_logos_orig$_ungrouped$UIWebView$initWithFrame$)(UIWebView*, SEL, CGRect); static id _logos_method$_ungrouped$UIWebView$initWithFrame$(UIWebView*, SEL, CGRect); static void (*_logos_orig$_ungrouped$UIWebView$webView$addMessageToConsole$)(UIWebView*, SEL, WebView *, NSDictionary *); static void _logos_method$_ungrouped$UIWebView$webView$addMessageToConsole$(UIWebView*, SEL, WebView *, NSDictionary *); static void (*_logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$)(UIWebView*, SEL, WebView *, WebScriptObject *, WebFrame *); static void _logos_method$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$(UIWebView*, SEL, WebView *, WebScriptObject *, WebFrame *); static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(SpringBoard*, SEL, id); 

#line 17 "/Users/Matt/iOS/Projects/InfoStats2/InfoStats2/InfoStats2.xm"


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
    
    
    NSString *href = [[[[frame dataSource] request] URL] absoluteString];
    if (href) {
        
        @try {
            WebCycriptSetupView(webview);
            NSLog(@"**** Cycript was injected into an UIWebView");
        } @catch (NSException *e) {
            NSLog(@"*** CydgetSetupContext => %@", e);
        }
    }
    
    _logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$(self, _cmd, webview, window, frame);
}



#pragma mark Helper for API



static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(SpringBoard* self, SEL _cmd, id arg1) {
    _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, arg1);
    
    [IS2Extensions initializeExtensions];
}



static __attribute__((constructor)) void _logosLocalCtor_d6d2aec7() {
    
    dlopen("/Library/MobileSubstrate/DynamicLibraries/iWidgets.dylib", RTLD_NOW);
    
    {Class _logos_class$_ungrouped$IWWidget = objc_getClass("IWWidget"); MSHookMessageEx(_logos_class$_ungrouped$IWWidget, @selector(webView:didClearWindowObject:forFrame:), (IMP)&_logos_method$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$, (IMP*)&_logos_orig$_ungrouped$IWWidget$webView$didClearWindowObject$forFrame$);Class _logos_class$_ungrouped$UIWebView = objc_getClass("UIWebView"); MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(initWithFrame:), (IMP)&_logos_method$_ungrouped$UIWebView$initWithFrame$, (IMP*)&_logos_orig$_ungrouped$UIWebView$initWithFrame$);MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(webView:addMessageToConsole:), (IMP)&_logos_method$_ungrouped$UIWebView$webView$addMessageToConsole$, (IMP*)&_logos_orig$_ungrouped$UIWebView$webView$addMessageToConsole$);MSHookMessageEx(_logos_class$_ungrouped$UIWebView, @selector(webView:didClearWindowObject:forFrame:), (IMP)&_logos_method$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$, (IMP*)&_logos_orig$_ungrouped$UIWebView$webView$didClearWindowObject$forFrame$);Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);}
}
