//
//  include.h
//  InfoStats2
//
//  Created by Matt Clarke on 05/04/2017.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <JavaScriptCore/JSContextRef.h>
#include <JavaScriptCore/JSObjectRef.h>

@class WebScriptObject, WebView, WebFrame;

@interface UIApplication (Apple)
- (void) applicationOpenURL:(NSURL *)url;
@end

@interface NSString (UIKit)
- (NSString *) stringByAddingPercentEscapes;
@end

@interface UIScroller : UIView
- (CGSize) contentSize;
- (void) setOffset:(CGPoint)offset;
@end

@interface UIWebDocumentView : UIView
- (WebView *) webView;
@end

@interface UIView (Apple)
- (UIScroller *) _scroller;
@end

@interface DOMCSSStyleSheet : NSObject
- (int) addRule:(NSString *)rule style:(NSString *)style index:(unsigned)index;
- (void) deleteRule:(unsigned)index;
@end

@interface DOMStyleSheetList : NSObject
- (DOMCSSStyleSheet *) item:(unsigned)index;
@end

@interface DOMDocument : NSObject
- (NSString *) selectedStylesheetSet;
- (void) setSelectedStylesheetSet:(NSString *)value;
- (DOMStyleSheetList *) styleSheets;
@end

@interface NSURL (Apple)
- (BOOL) isSpringboardHandledURL;
@end

@interface UIWebView (Apple)
- (UIWebDocumentView *) _documentView;
- (void) setDataDetectorTypes:(NSInteger)types;
- (void) _setDrawInWebThread:(BOOL)draw;
- (UIScrollView *) _scrollView;
- (UIScroller *) _scroller;
- (void) webView:(WebView *)view addMessageToConsole:(NSDictionary *)message;
- (void) webView:(WebView *)view didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame;
@end

@interface WebView : NSObject
@property (nonatomic, readonly) WebFrame *mainFrame;
+ (void)registerURLSchemeAsLocal:(id)arg1;
@end

@interface WebFrame : NSObject
@property (nonatomic, readonly) JSGlobalContextRef globalContext;
- (id)DOMDocument;
@end

@protocol CydgetWebViewDelegate <UIWebViewDelegate>
- (void) webView:(WebView *)view didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame;
@end

#include <string>

struct State {
    unsigned state;
};

namespace JSC {
    class JSGlobalData;
    class UString;
}

namespace WebCore {
    class KURL;
}

namespace WebCore {
    struct String {
        void *impl_;
    };
}

namespace JSC {
    struct SourceCode {
        void *provider_;
        int start_;
        int end_;
        int line_;
    };
}

namespace JSC {
    union ScriptSourceCode {
        struct {
            JSC::SourceCode source_;
        } Old;
        struct {
            void *provider_;
            JSC::SourceCode source_;
        } New;
    };
}

class CFStringStruct {
private:
    CFStringRef value_;
    
public:
    CFStringStruct() :
    value_(NULL)
    {
    }
    
    CFStringStruct(const CFStringStruct &value) :
    value_((CFStringRef) CFRetain(value.value_))
    {
    }
    
    ~CFStringStruct() {
    }
    
    operator CFStringRef() const {
        return value_;
    }
    
    operator NSString *() const {
        return (__bridge NSString *) value_;
    }
};

namespace WebCore {
    class MediaQueryEvaluator;
    class CSSParserValueList;
}

namespace WebCore {
    struct MediaQueryExp {
        String feature_;
        void *value_;
        bool valid_;
        String cache_;
    };
}

