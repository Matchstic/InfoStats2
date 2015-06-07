#import <objc/runtime.h>
#import "IS2WebView.h"
#include "WebCycript.h"

@interface CIWExtensions : NSObject
+(void)initializeExtensions;
@end

@interface IWWidget : UIView {
    UIWebView *_webView;
}
- (void)webView:(id)arg1 didClearWindowObject:(id)arg2 forFrame:(id)arg3;
@end

@interface SBIconView : UIView
- (id)initWithDefaultSize;
- (id)_newCloseBoxOfType:(int)type;
@end

%hook IWWidget

- (void)webView:(id)arg1 didClearWindowObject:(id)arg2 forFrame:(id)arg3 {
    UIWebView *webView = MSHookIvar<UIWebView*>(self, "_webView");
    [webView webView:arg1 didClearWindowObject:arg2 forFrame:arg3];
    
    %orig;
}

%end

// Fix for iWidgets on iOS 6 and below

%hook UIView

%new

-(id)_newCloseBoxOfType:(int)type {
    SBIconView *view = [[objc_getClass("SBIconView") alloc] initWithDefaultSize];
    return [view _newCloseBoxOfType:type];
}

%end

%hook UIWebView

-(id)initWithFrame:(CGRect)frame {
    UIWebView *original = %orig;
    
    /*NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    if ([[array objectAtIndex:4] isEqualToString:@"iWidgets"]) {*/
        //object_setClass(original, [IS2WebView class]);
        
        UIWebDocumentView *document = [original _documentView];
        WebView *webview = [document webView];
        
        [webview setPreferencesIdentifier:@"WebCycript"];
        
        if ([webview respondsToSelector:@selector(_setAllowsMessaging:)])
            [webview _setAllowsMessaging:YES];
    //}
    
    return original;
}

-(void)webView:(WebView *)view addMessageToConsole:(NSDictionary *)message {
    NSLog(@"addMessageToConsole: %@", message);
    
    if ([UIWebView instancesRespondToSelector:@selector(webView:addMessageToConsole:)])
        %orig;
}

- (void)webView:(WebView *)webview didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame {
    NSObject<CIWDelegate> *delegate = (NSObject<CIWDelegate> *)[self delegate];
    if ([delegate respondsToSelector:@selector(webView:didClearWindowObject:forFrame:)])
        [delegate webView:webview didClearWindowObject:window forFrame:frame];
    
    NSString *href = [[[[frame dataSource] request] URL] absoluteString];
    if (href) {
        // Inject Cycript into this webview. If we're in Cydget, this *should* work fine.
        
        @try {
            WebCycriptSetupView(webview);
            NSLog(@"**** Cycript was injected into an UIWebView");
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
    
    [CIWExtensions initializeExtensions];
}

%end

%ctor {
    // Load up iWidgets dylib
    dlopen("/Library/MobileSubstrate/DynamicLibraries/iWidgets.dylib", RTLD_NOW);
    
    %init;
}