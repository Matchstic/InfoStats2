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

// Needed to inject into iWidgets

%hook IWWidget

- (void)webView:(id)arg1 didClearWindowObject:(id)arg2 forFrame:(id)arg3 {
    UIWebView *webView = MSHookIvar<UIWebView*>(self, "_webView");
    [webView webView:arg1 didClearWindowObject:arg2 forFrame:arg3];
    
    %orig;
}

%end

#pragma mark Injection of Cycript into WebViews

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
    if ([[self class] isEqual:[objc_getClass("CydgetWebView") class]]) {
        // No need to inject Cycript into Cydget
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

#pragma mark Helper for API

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    
    [IS2Extensions initializeExtensions];
}

%end

%ctor {
    // Load up iWidgets dylib to hook it
    dlopen("/Library/MobileSubstrate/DynamicLibraries/iWidgets.dylib", RTLD_NOW);
    
    %init;
}