#line 1 "/Users/Matt/iOS/Projects/InfoStats2/WebCycript/WebCycript.xm"





















#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>
#include <map>
#include <substrate.h>

#include "WebCycript.h"
#import "include.h"
#import "yieldToSelector.h"
#import "CydgetURLProtocol.h"
#import "CydgetCGIURLProtocol.h"




extern "C" UIImage *_UIImageWithName(NSString *name);

typedef uint16_t UChar;
typedef std::map<std::string, BOOL (*)()> StyleMap_;




static StyleMap_ styles_;
static CGFloat systemVersion;

static void showAlert(NSString *message) {
    NSLog(@"WEBCYCRIPT: %@", message);
}




extern "C" void WebCycriptSetupView(WebView *webview) {
    if (void *handle = dlopen("/usr/lib/libcycript.dylib", RTLD_LAZY | RTLD_GLOBAL)) {
        if (void (*CYSetupContext)(JSGlobalContextRef) = reinterpret_cast<void (*)(JSGlobalContextRef)>(dlsym(handle, "CydgetSetupContext"))) {
            WebFrame *frame = [webview mainFrame];
            JSGlobalContextRef context = [frame globalContext];
            @try {
                CYSetupContext(context);
                showAlert(@"INJECTED");
            } @catch (NSException *e) {
                NSLog(@"*** CydgetSetupContext => %@", e);
                showAlert(@"FAILED TO BE INJECTED (excp)");
            }
        } else {
            showAlert(@"FAILED TO BE INJECTED (symb)");
        }
    } else {
        showAlert(@"FAILED TO BE INJECTED (handle)");
    }
}

extern "C" void WebCycriptRegisterStyle(const char *name, BOOL (*code)()) {
    styles_.insert(std::make_pair(name, code));
}





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

@class UIWebDocumentView; @class UIWebView; @class WebView; @class NSURL; @class UIApplication; 
static void _logos_method$_ungrouped$UIWebDocumentView$_setScrollerOffset$(_LOGOS_SELF_TYPE_NORMAL UIWebDocumentView* _LOGOS_SELF_CONST, SEL, CGPoint); static void (*_logos_orig$_ungrouped$UIApplication$openURL$)(_LOGOS_SELF_TYPE_NORMAL UIApplication* _LOGOS_SELF_CONST, SEL, NSURL *); static void _logos_method$_ungrouped$UIApplication$openURL$(_LOGOS_SELF_TYPE_NORMAL UIApplication* _LOGOS_SELF_CONST, SEL, NSURL *); static NSNumber * _logos_method$_ungrouped$NSURL$cydget$isSpringboardHandledURL(_LOGOS_SELF_TYPE_NORMAL NSURL* _LOGOS_SELF_CONST, SEL); static BOOL (*_logos_orig$_ungrouped$NSURL$isSpringboardHandledURL)(_LOGOS_SELF_TYPE_NORMAL NSURL* _LOGOS_SELF_CONST, SEL); static BOOL _logos_method$_ungrouped$NSURL$isSpringboardHandledURL(_LOGOS_SELF_TYPE_NORMAL NSURL* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$UIWebView$updateStyles(_LOGOS_SELF_TYPE_NORMAL UIWebView* _LOGOS_SELF_CONST, SEL); static void (*_logos_meta_orig$_ungrouped$WebView$enableWebThread)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static void _logos_meta_method$_ungrouped$WebView$enableWebThread(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); 

#line 82 "/Users/Matt/iOS/Projects/InfoStats2/WebCycript/WebCycript.xm"



static void _logos_method$_ungrouped$UIWebDocumentView$_setScrollerOffset$(_LOGOS_SELF_TYPE_NORMAL UIWebDocumentView* _LOGOS_SELF_CONST self, SEL _cmd, CGPoint offset) {
    UIScroller *scroller = [self _scroller];
    
    CGSize size = [scroller contentSize];
    CGSize bounds = [scroller bounds].size;
    
    CGPoint max;
    max.x = size.width - bounds.width;
    max.y = size.height - bounds.height;
    
    
    if (max.x < 0)
        max.x = 0;
    if (max.y < 0)
        max.y = 0;
            
    offset.x = offset.x < 0 ? 0 : offset.x > max.x ? max.x : offset.x;
    offset.y = offset.y < 0 ? 0 : offset.y > max.y ? max.y : offset.y;
            
    [scroller setOffset:offset];
}



#pragma mark URL opening



static void _logos_method$_ungrouped$UIApplication$openURL$(_LOGOS_SELF_TYPE_NORMAL UIApplication* _LOGOS_SELF_CONST self, SEL _cmd, NSURL * url) {
    [self applicationOpenURL:url];
}






static NSNumber * _logos_method$_ungrouped$NSURL$cydget$isSpringboardHandledURL(_LOGOS_SELF_TYPE_NORMAL NSURL* _LOGOS_SELF_CONST self, SEL _cmd) {
    return [NSNumber numberWithBool:[self isSpringboardHandledURL]];
}

static BOOL _logos_method$_ungrouped$NSURL$isSpringboardHandledURL(_LOGOS_SELF_TYPE_NORMAL NSURL* _LOGOS_SELF_CONST self, SEL _cmd) {
    if (![NSThread isMainThread])
        return _logos_orig$_ungrouped$NSURL$isSpringboardHandledURL(self, _cmd);
    
    return [[self cydget$yieldToSelector:@selector(cydget$isSpringboardHandledURL)] boolValue];
}






static void _logos_method$_ungrouped$UIWebView$updateStyles(_LOGOS_SELF_TYPE_NORMAL UIWebView* _LOGOS_SELF_CONST self, SEL _cmd) {
    DOMDocument *document = [[[[self _documentView] webView] mainFrame] DOMDocument];
    [document setSelectedStylesheetSet:[document selectedStylesheetSet]];
}



#pragma mark String Helpers

static const UChar *(*_ZNK7WebCore6String10charactersEv)(const WebCore::String *);
static const UChar *(*_ZN7WebCore6String29charactersWithNullTerminationEv)(const WebCore::String *);
static CFStringStruct (*_ZNK3WTF6String14createCFStringEv)(const WebCore::String *);
static unsigned (*_ZNK7WebCore6String6lengthEv)(const WebCore::String *);

static bool StringGet(const WebCore::String &string, const UChar *&data, size_t &length) {
    bool terminated;
    
    if (_ZNK7WebCore6String10charactersEv != NULL) {
        data = (*_ZNK7WebCore6String10charactersEv)(&string);
        terminated = false;
    } else if (_ZN7WebCore6String29charactersWithNullTerminationEv != NULL) {
        data = (*_ZN7WebCore6String29charactersWithNullTerminationEv)(&string);
        terminated = true;
    } else if (_ZNK3WTF6String14createCFStringEv != NULL) {
        CFStringStruct cf((*_ZNK3WTF6String14createCFStringEv)(&string));
        data = (const UChar *) [cf cStringUsingEncoding:NSUTF16StringEncoding];
        length = CFStringGetLength(cf);
        return true;
    } else return false;
    
    if (data == NULL)
        return false;
    
    if (_ZNK7WebCore6String6lengthEv != NULL)
        length = (*_ZNK7WebCore6String6lengthEv)(&string);
    else if (terminated)
        for (length = 0; data[length] != 0; ++length);
    else return false;
    
    return true;
}

static bool StringEquals(const WebCore::String &string, const char *value) {
    const UChar *data;
    size_t size;
    if (!StringGet(string, data, size))
        return false;
    
    size_t length(strlen(value));
    if (size != length)
        return false;
    
    for (size_t index(0); index != length; ++index)
        if (data[index] != value[index])
            return false;
    
    return true;
}
 
 
#pragma mark State Machine
 
static bool cycript_;

_disused static bool (*_logos_orig$_ungrouped$lookup$_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE)(const WebCore::String &mime); static bool _logos_function$_ungrouped$lookup$_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE(const WebCore::String &mime) {
    if (!StringEquals(mime, "text/cycript")) {
        cycript_ = false;
        showAlert(@"_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE - invalid");
        return _logos_orig$_ungrouped$lookup$_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE(mime);
    }
    
    static void *handle = dlopen("/usr/lib/libcycript.dylib", RTLD_LAZY | RTLD_GLOBAL);
    if (handle == NULL)
        return false;
    
    showAlert(@"_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE - is valid");
    
    cycript_ = true;
    return true;
}
 
#pragma mark Script Compiler
 
static void Log(const WebCore::String &string) {
#if 1
    const UChar *data;
    size_t length;
    if (!StringGet(string, data, length))
        return;
    
    UChar terminated[length + 1];
    terminated[length] = 0;
    memcpy(terminated, data, length * 2);
    NSLog(@"wtf %p:%zu:%S:", &string, length, terminated);
#endif
}

static bool Cycriptify(const uint16_t *&data, size_t &size) {
    cycript_ = false;
    
    if (void *handle = dlopen("/usr/lib/libcycript.dylib", RTLD_LAZY | RTLD_GLOBAL))
        if (void (*CydgetMemoryParse)(const uint16_t **, size_t *) = reinterpret_cast<void (*)(const uint16_t **, size_t *)>(dlsym(handle, "CydgetMemoryParse"))) @try {
            CydgetMemoryParse(&data, &size);
            return true;
        } @catch (NSException *e) {
            NSLog(@"*** CydgetMemoryParse => %@", e);
        }
    return false;
}

static void (*_ZN7WebCore6String6appendEPKtj)(WebCore::String *, const UChar *, unsigned);
static void (*_ZN7WebCore6String8truncateEj)(WebCore::String *, unsigned);

static void Cycriptify(const WebCore::String &source, int *psize = NULL) {
    if (!cycript_)
        return;
    cycript_ = false;
    
    const UChar *data;
    size_t length;
    if (!StringGet(source, data, length))
        return;
    
    size_t size(length);
    if (!Cycriptify(data, size))
        return;
    
    WebCore::String &script(const_cast<WebCore::String &>(source));
    _ZN7WebCore6String8truncateEj(&script, 0);
    _ZN7WebCore6String6appendEPKtj(&script, data, (unsigned int)size);
    
    if (psize != NULL)
        *psize = (int)size;
    
    free((void *) data);
    
    Log(source);
}

static WebCore::String *string;


_disused static State (*_logos_orig$_ungrouped$lookup$_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i)(void *_this, const WebCore::String &string, State state, const WebCore::String &url, int line); static State _logos_function$_ungrouped$lookup$_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i(void *_this, const WebCore::String &string, State state, const WebCore::String &url, int line) {
    showAlert(@"_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i");
    Cycriptify(string);
    return _logos_orig$_ungrouped$lookup$_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i(_this, string, state, url, line);
}


_disused static const WebCore::String & (*_logos_orig$_ungrouped$lookup$_ZNK7WebCore4Node11textContentEb)(void *_this, bool convert); static const WebCore::String & _logos_function$_ungrouped$lookup$_ZNK7WebCore4Node11textContentEb(void *_this, bool convert) {
    const WebCore::String &code = _logos_orig$_ungrouped$lookup$_ZNK7WebCore4Node11textContentEb(_this, convert);
    string = const_cast<WebCore::String *>(&code);
    showAlert(@"_ZNK7WebCore4Node11textContentEb");
    Cycriptify(code);
    return code;
}


_disused static void (*_logos_orig$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi)(void *_this, const WebCore::String &source, const WebCore::KURL &url, int line); static void _logos_function$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi(void *_this, const WebCore::String &source, const WebCore::KURL &url, int line) {
    showAlert(@"_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi");
    Cycriptify(source);
    return _logos_orig$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi(_this, source, url, line);
}


_disused static const WebCore::String & (*_logos_orig$_ungrouped$lookup$_ZN7WebCore12CachedScript6scriptEv)(void *_this); static const WebCore::String & _logos_function$_ungrouped$lookup$_ZN7WebCore12CachedScript6scriptEv(void *_this) {
    
    
    showAlert(@"_ZN7WebCore12CachedScript6scriptEv");
    
    if (systemVersion >= 10.0) {
        
    }
    
    const WebCore::String &script = _logos_orig$_ungrouped$lookup$_ZN7WebCore12CachedScript6scriptEv(_this);
    string = const_cast<WebCore::String *>(&script);
    return script;
}


_disused static State (*_logos_orig$_ungrouped$lookup$_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE)(void *_this, JSC::ScriptSourceCode &script, State state); static State _logos_function$_ungrouped$lookup$_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE(void *_this, JSC::ScriptSourceCode &script, State state) {
    if (string != NULL) {
        showAlert(@"_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE - nonnull");
        JSC::SourceCode *source = systemVersion >= 4.0 ? &script.New.source_ : &script.Old.source_;
        Cycriptify(*string, &source->end_);
        string = NULL;
    } else {
        showAlert(@"_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE - null");
    }
    
    return _logos_orig$_ungrouped$lookup$_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE(_this, script, state);
}


_disused static void (*_logos_orig$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE)(void *_this, const WebCore::String &source, const WebCore::KURL &url, void *position); static void _logos_function$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE(void *_this, const WebCore::String &source, const WebCore::KURL &url, void *position) {
    showAlert(@"_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE");
    Cycriptify(source);
    return _logos_orig$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE(_this, source, url, position);
}


_disused static void (*_logos_orig$_ungrouped$lookup$_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE)(void *_this, void *position, int legacy); static void _logos_function$_ungrouped$lookup$_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE(void *_this, void *position, int legacy) {
    
    showAlert(@"_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE");
    
    string = NULL;
    return _logos_orig$_ungrouped$lookup$_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE(_this, position, legacy);
}

void (*$_ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE)(void *_this, int legacy);


_disused static void (*_logos_orig$_ungrouped$lookup$_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE)(void *_this, JSC::ScriptSourceCode &script); static void _logos_function$_ungrouped$lookup$_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE(void *_this, JSC::ScriptSourceCode &script) {
    if (string != NULL) {
        showAlert(@"_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE - nonnull");
        JSC::SourceCode *source = &script.New.source_;
        $_ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE(_this, 0);
        Cycriptify(*string, &source->end_);
        string = NULL;
    } else {
        showAlert(@"_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE - null");
    }
    
    return _logos_orig$_ungrouped$lookup$_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE(_this, script);
}


_disused static void (*_logos_orig$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE)(void *_this, const WebCore::String &source, const WebCore::KURL &url, void *position); static void _logos_function$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE(void *_this, const WebCore::String &source, const WebCore::KURL &url, void *position) {
    showAlert(@"_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE");
    Cycriptify(source);
    return _logos_orig$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE(_this, source, url, position);
}


_disused static void (*_logos_orig$_ungrouped$lookup$_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE)(void *_this, void *position, int legacy); static void _logos_function$_ungrouped$lookup$_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE(void *_this, void *position, int legacy) {
    showAlert(@"_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE");
    string = NULL;
    return _logos_orig$_ungrouped$lookup$_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE(_this, position, legacy);
}

#pragma mark Media Hooks

_disused static bool (*_logos_orig$_ungrouped$lookup$_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE)(WebCore::MediaQueryEvaluator *_this, WebCore::String &query); static bool _logos_function$_ungrouped$lookup$_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE(WebCore::MediaQueryEvaluator *_this, WebCore::String &query) {
    Log(query);
    
    for (StyleMap_::const_iterator style(styles_.begin()); style != styles_.end(); ++style)
        if (StringEquals(query, style->first.c_str()))
            return style->second();
    
    return _logos_orig$_ungrouped$lookup$_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE(_this, query);
}

_disused static void * (*_logos_orig$_ungrouped$lookup$_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE)(WebCore::MediaQueryExp *_this, WebCore::String &query, WebCore::CSSParserValueList *values); static void * _logos_function$_ungrouped$lookup$_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE(WebCore::MediaQueryExp *_this, WebCore::String &query, WebCore::CSSParserValueList *values) {
    Log(query);
    
    void *value = _logos_orig$_ungrouped$lookup$_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE(_this, query, values);
    if (!_this->valid_)
        for (StyleMap_::const_iterator style(styles_.begin()); style != styles_.end(); ++style)
            if (StringEquals(query, style->first.c_str()))
                _this->valid_ = true;
    
    return value;
}



static void _logos_meta_method$_ungrouped$WebView$enableWebThread(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST self, SEL _cmd) {
    if (systemVersion >= 3.2)
        return _logos_meta_orig$_ungrouped$WebView$enableWebThread(self, _cmd);
        
    NSLog(@"-[WebView enableWebThread]");
}



#define msset(function, handle) \
MSHookSymbol(function, "_" #function, handle)

static __attribute__((constructor)) void _logosLocalCtor_db383536(int argc, char **argv, char **envp) {
    systemVersion = [[UIDevice currentDevice] systemVersion].floatValue;
    
    [NSURLProtocol registerClass:[CydgetURLProtocol class]];
    [WebView registerURLSchemeAsLocal:@"cydget"];
    
    [NSURLProtocol registerClass:[CydgetCGIURLProtocol class]];
    [WebView registerURLSchemeAsLocal:@"cydget-cgi"];
    
    showAlert(@"CONSTRUCTOR");
    
    
    void *JavaScriptCore = NULL;
    if (JavaScriptCore == NULL)
        JavaScriptCore = (void*)MSGetImageByName("/System/Library/Frameworks/JavaScriptCore.framework/JavaScriptCore");
    if (JavaScriptCore == NULL)
        JavaScriptCore = (void*)MSGetImageByName("/System/Library/PrivateFrameworks/JavaScriptCore.framework/JavaScriptCore");
            
    
    void *WebCore = (void*)MSGetImageByName("/System/Library/PrivateFrameworks/WebCore.framework/WebCore");
    
    {Class _logos_class$_ungrouped$UIWebDocumentView = objc_getClass("UIWebDocumentView"); { char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(CGPoint), strlen(@encode(CGPoint))); i += strlen(@encode(CGPoint)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIWebDocumentView, @selector(_setScrollerOffset:), (IMP)&_logos_method$_ungrouped$UIWebDocumentView$_setScrollerOffset$, _typeEncoding); }Class _logos_class$_ungrouped$UIApplication = objc_getClass("UIApplication"); if (_logos_class$_ungrouped$UIApplication) {MSHookMessageEx(_logos_class$_ungrouped$UIApplication, @selector(openURL:), (IMP)&_logos_method$_ungrouped$UIApplication$openURL$, (IMP*)&_logos_orig$_ungrouped$UIApplication$openURL$);} else {HBLogError(@"logos: nil class %s", "UIApplication");}Class _logos_class$_ungrouped$NSURL = objc_getClass("NSURL"); { char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(NSNumber *), strlen(@encode(NSNumber *))); i += strlen(@encode(NSNumber *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$NSURL, @selector(cydget$isSpringboardHandledURL), (IMP)&_logos_method$_ungrouped$NSURL$cydget$isSpringboardHandledURL, _typeEncoding); }if (_logos_class$_ungrouped$NSURL) {MSHookMessageEx(_logos_class$_ungrouped$NSURL, @selector(isSpringboardHandledURL), (IMP)&_logos_method$_ungrouped$NSURL$isSpringboardHandledURL, (IMP*)&_logos_orig$_ungrouped$NSURL$isSpringboardHandledURL);} else {HBLogError(@"logos: nil class %s", "NSURL");}Class _logos_class$_ungrouped$UIWebView = objc_getClass("UIWebView"); { char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIWebView, @selector(updateStyles), (IMP)&_logos_method$_ungrouped$UIWebView$updateStyles, _typeEncoding); }Class _logos_class$_ungrouped$WebView = objc_getClass("WebView"); Class _logos_metaclass$_ungrouped$WebView = object_getClass(_logos_class$_ungrouped$WebView); if (_logos_metaclass$_ungrouped$WebView) {MSHookMessageEx(_logos_metaclass$_ungrouped$WebView, @selector(enableWebThread), (IMP)&_logos_meta_method$_ungrouped$WebView$enableWebThread, (IMP*)&_logos_meta_orig$_ungrouped$WebView$enableWebThread);} else {HBLogError(@"logos: nil class %s", "WebView");} MSHookFunction((void *)MSFindSymbol(NULL, "_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE"), (void *)&_logos_function$_ungrouped$lookup$_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE, (void **)&_logos_orig$_ungrouped$lookup$_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE); MSHookFunction((void *)MSFindSymbol(NULL, "_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i"), (void *)&_logos_function$_ungrouped$lookup$_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i, (void **)&_logos_orig$_ungrouped$lookup$_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i); MSHookFunction((void *)MSFindSymbol(NULL, "_ZNK7WebCore4Node11textContentEb"), (void *)&_logos_function$_ungrouped$lookup$_ZNK7WebCore4Node11textContentEb, (void **)&_logos_orig$_ungrouped$lookup$_ZNK7WebCore4Node11textContentEb); MSHookFunction((void *)MSFindSymbol(NULL, "_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi"), (void *)&_logos_function$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi, (void **)&_logos_orig$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi); MSHookFunction((void *)MSFindSymbol(NULL, "_ZN7WebCore12CachedScript6scriptEv"), (void *)&_logos_function$_ungrouped$lookup$_ZN7WebCore12CachedScript6scriptEv, (void **)&_logos_orig$_ungrouped$lookup$_ZN7WebCore12CachedScript6scriptEv); MSHookFunction((void *)MSFindSymbol(NULL, "_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE"), (void *)&_logos_function$_ungrouped$lookup$_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE, (void **)&_logos_orig$_ungrouped$lookup$_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE); MSHookFunction((void *)MSFindSymbol(NULL, "_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE"), (void *)&_logos_function$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE, (void **)&_logos_orig$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE); MSHookFunction((void *)MSFindSymbol(NULL, "_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE"), (void *)&_logos_function$_ungrouped$lookup$_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE, (void **)&_logos_orig$_ungrouped$lookup$_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE); MSHookFunction((void *)MSFindSymbol(NULL, "_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE"), (void *)&_logos_function$_ungrouped$lookup$_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE, (void **)&_logos_orig$_ungrouped$lookup$_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE); MSHookFunction((void *)MSFindSymbol(NULL, "_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE"), (void *)&_logos_function$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE, (void **)&_logos_orig$_ungrouped$lookup$_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE); MSHookFunction((void *)MSFindSymbol(NULL, "_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE"), (void *)&_logos_function$_ungrouped$lookup$_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE, (void **)&_logos_orig$_ungrouped$lookup$_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE); MSHookFunction((void *)MSFindSymbol(NULL, "_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE"), (void *)&_logos_function$_ungrouped$lookup$_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE, (void **)&_logos_orig$_ungrouped$lookup$_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE); MSHookFunction((void *)MSFindSymbol(NULL, "_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE"), (void *)&_logos_function$_ungrouped$lookup$_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE, (void **)&_logos_orig$_ungrouped$lookup$_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE);}
    
    
    
    
    MSHookSymbol($_ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE, "__ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE", WebCore);
    
    
    if (_ZN7WebCore6String6appendEPKtj == NULL)
        MSHookSymbol(_ZN7WebCore6String6appendEPKtj, "__ZN7WebCore6String6appendEPKtj", WebCore);
    if (_ZN7WebCore6String6appendEPKtj == NULL)
        msset(_ZN7WebCore6String6appendEPKtj, JavaScriptCore);
    if (_ZN7WebCore6String6appendEPKtj == NULL)
        MSHookSymbol(_ZN7WebCore6String6appendEPKtj, "__ZN3WTF6String6appendEPKtj", JavaScriptCore);
    
    if (_ZN7WebCore6String8truncateEj == NULL)
        MSHookSymbol(_ZN7WebCore6String8truncateEj, "__ZN7WebCore6String8truncateEj", WebCore);
    if (_ZN7WebCore6String8truncateEj == NULL)
        msset(_ZN7WebCore6String8truncateEj, JavaScriptCore);
    if (_ZN7WebCore6String8truncateEj == NULL)
        MSHookSymbol(_ZN7WebCore6String8truncateEj, "__ZN3WTF6String8truncateEj", JavaScriptCore);
        
    msset(_ZNK7WebCore6String10charactersEv, WebCore);
        
    msset(_ZN7WebCore6String29charactersWithNullTerminationEv, JavaScriptCore);
    if (_ZN7WebCore6String29charactersWithNullTerminationEv == NULL)
        MSHookSymbol(_ZN7WebCore6String29charactersWithNullTerminationEv, "__ZN3WTF6String29charactersWithNullTerminationEv", JavaScriptCore);
            
    msset(_ZNK3WTF6String14createCFStringEv, JavaScriptCore);
            
    msset(_ZNK7WebCore6String6lengthEv, WebCore);
}
