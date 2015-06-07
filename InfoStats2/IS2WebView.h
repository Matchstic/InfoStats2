//
//  IS2WebView.h
//  InfoStats2
//
//  Created by Matt Clarke on 02/06/2015.
//
//

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

@protocol CIWDelegate <NSObject>
- (void)webView:(WebView *)webview didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame;
@end

/*@interface IS2WebView : UIWebView

@end*/
