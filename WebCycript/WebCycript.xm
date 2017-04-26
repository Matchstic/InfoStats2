/* Cydget - open-source AwayView plugin multiplexer
 * Copyright (C) 2009-2015  Jay Freeman (saurik)
 */

/* GNU General Public License, Version 3 {{{ */
/*
 * Cydget is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * Cydget is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Cydget.  If not, see <http://www.gnu.org/licenses/>.
 **/
/* }}} */

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

////////////////////////////////////////////////////////////////////////////////
// Definitions

extern "C" UIImage *_UIImageWithName(NSString *name);

typedef uint16_t UChar;
typedef std::map<std::string, BOOL (*)()> StyleMap_;

////////////////////////////////////////////////////////////////////////////////
// Static variables

static StyleMap_ styles_;
static CGFloat systemVersion;

static void showAlert(NSString *message) {
    NSLog(@"WEBCYCRIPT: %@", message);
}

////////////////////////////////////////////////////////////////////////////////
// Exported API

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

////////////////////////////////////////////////////////////////////////////////
// Hooks and other fun things.

%hook UIWebDocumentView

%new
- (void)_setScrollerOffset:(CGPoint)offset {
    UIScroller *scroller = [self _scroller];
    
    CGSize size = [scroller contentSize];
    CGSize bounds = [scroller bounds].size;
    
    CGPoint max;
    max.x = size.width - bounds.width;
    max.y = size.height - bounds.height;
    
    // wtf Apple?!
    if (max.x < 0)
        max.x = 0;
    if (max.y < 0)
        max.y = 0;
            
    offset.x = offset.x < 0 ? 0 : offset.x > max.x ? max.x : offset.x;
    offset.y = offset.y < 0 ? 0 : offset.y > max.y ? max.y : offset.y;
            
    [scroller setOffset:offset];
}

%end

#pragma mark URL opening

%hook UIApplication

- (void)openURL:(NSURL *)url {
    [self applicationOpenURL:url];
}

%end

%hook NSURL

%new
- (NSNumber *) cydget$isSpringboardHandledURL {
    return [NSNumber numberWithBool:[self isSpringboardHandledURL]];
}

- (BOOL)isSpringboardHandledURL {
    if (![NSThread isMainThread])
        return %orig;
    
    return [[self cydget$yieldToSelector:@selector(cydget$isSpringboardHandledURL)] boolValue];
}

%end

%hook UIWebView

%new
- (void) updateStyles {
    DOMDocument *document = [[[[self _documentView] webView] mainFrame] DOMDocument];
    [document setSelectedStylesheetSet:[document selectedStylesheetSet]];
}

%end

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

%hookf(bool, "_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE", const WebCore::String &mime) {
    if (!StringEquals(mime, "text/cycript")) {
        cycript_ = false;
        showAlert(@"_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE - invalid");
        return %orig(mime);
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

// iOS 2.x
%hookf(State, "_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i", void *_this, const WebCore::String &string, State state, const WebCore::String &url, int line) {
    showAlert(@"_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i");
    Cycriptify(string);
    return %orig(_this, string, state, url, line);
}

// iOS 3.x cdata
%hookf(const WebCore::String &, "_ZNK7WebCore4Node11textContentEb", void *_this, bool convert) {
    const WebCore::String &code = %orig(_this, convert);
    string = const_cast<WebCore::String *>(&code);
    showAlert(@"_ZNK7WebCore4Node11textContentEb");
    Cycriptify(code);
    return code;
}

// iOS 4.x cdata
%hookf(void, "_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi", void *_this, const WebCore::String &source, const WebCore::KURL &url, int line) {
    showAlert(@"_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi");
    Cycriptify(source);
    return %orig(_this, source, url, line);
}

// iOS 4.x+5.0 @src=
%hookf(const WebCore::String &, "_ZN7WebCore12CachedScript6scriptEv", void *_this) {
    // XXX: For some reason, this will lead to a SIGBUS on iOS 10. Research needed!
    
    showAlert(@"_ZN7WebCore12CachedScript6scriptEv");
    
    if (systemVersion >= 10.0) {
        //return %orig;
    }
    
    const WebCore::String &script = %orig(_this);
    string = const_cast<WebCore::String *>(&script);
    return script;
}

// iOS 4.x @src=
%hookf(State, "_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE", void *_this, JSC::ScriptSourceCode &script, State state) {
    if (string != NULL) {
        showAlert(@"_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE - nonnull");
        JSC::SourceCode *source = systemVersion >= 4.0 ? &script.New.source_ : &script.Old.source_;
        Cycriptify(*string, &source->end_);
        string = NULL;
    } else {
        showAlert(@"_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE - null");
    }
    
    return %orig(_this, script, state);
}

// iOS 5.0 cdata
%hookf(void, "_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE", void *_this, const WebCore::String &source, const WebCore::KURL &url, void *position) {
    showAlert(@"_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE");
    Cycriptify(source);
    return %orig(_this, source, url, position);
}

// iOS 5.0 @src=
%hookf(void, "_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE", void *_this, void *position, int legacy) {
    
    showAlert(@"_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE");
    
    string = NULL;
    return %orig(_this, position, legacy);
}

void (*$_ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE)(void *_this, int legacy);

// iOS 5.0 @src=
%hookf(void, "_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE", void *_this, JSC::ScriptSourceCode &script) {
    if (string != NULL) {
        showAlert(@"_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE - nonnull");
        JSC::SourceCode *source = &script.New.source_;
        $_ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE(_this, 0);
        Cycriptify(*string, &source->end_);
        string = NULL;
    } else {
        showAlert(@"_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE - null");
    }
    
    return %orig(_this, script);
}

// iOS 6.0 cdata
%hookf(void, "_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE", void *_this, const WebCore::String &source, const WebCore::KURL &url, void *position) {
    showAlert(@"_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE");
    Cycriptify(source);
    return %orig(_this, source, url, position);
}

// iOS 6.0 @src=
%hookf(void, "_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE", void *_this, void *position, int legacy) {
    showAlert(@"_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE");
    string = NULL;
    return %orig(_this, position, legacy);
}

#pragma mark Media Hooks

%hookf(bool, "_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE", WebCore::MediaQueryEvaluator *_this, WebCore::String &query) {
    Log(query);
    
    for (StyleMap_::const_iterator style(styles_.begin()); style != styles_.end(); ++style)
        if (StringEquals(query, style->first.c_str()))
            return style->second();
    
    return %orig(_this, query);
}

%hookf(void *, "_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE", WebCore::MediaQueryExp *_this, WebCore::String &query, WebCore::CSSParserValueList *values) {
    Log(query);
    
    void *value = %orig(_this, query, values);
    if (!_this->valid_)
        for (StyleMap_::const_iterator style(styles_.begin()); style != styles_.end(); ++style)
            if (StringEquals(query, style->first.c_str()))
                _this->valid_ = true;
    
    return value;
}

%hook WebView

+ (void)enableWebThread {
    if (systemVersion >= 3.2)
        return %orig;
        
    NSLog(@"-[WebView enableWebThread]");
}

%end

#define msset(function, handle) \
MSHookSymbol(function, "_" #function, handle)

%ctor {
    systemVersion = [[UIDevice currentDevice] systemVersion].floatValue;
    
    [NSURLProtocol registerClass:[CydgetURLProtocol class]];
    [WebView registerURLSchemeAsLocal:@"cydget"];
    
    [NSURLProtocol registerClass:[CydgetCGIURLProtocol class]];
    [WebView registerURLSchemeAsLocal:@"cydget-cgi"];
    
    showAlert(@"CONSTRUCTOR");
    
    // Get JavaScriptCore.
    void *JavaScriptCore = NULL;
    if (JavaScriptCore == NULL)
        JavaScriptCore = (void*)MSGetImageByName("/System/Library/Frameworks/JavaScriptCore.framework/JavaScriptCore");
    if (JavaScriptCore == NULL)
        JavaScriptCore = (void*)MSGetImageByName("/System/Library/PrivateFrameworks/JavaScriptCore.framework/JavaScriptCore");
            
    // Get WebCore.
    void *WebCore = (void*)MSGetImageByName("/System/Library/PrivateFrameworks/WebCore.framework/WebCore");
    
    %init;
    
    // Symbol binding
    
    // Script type supported
    MSHookSymbol($_ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE, "__ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE", WebCore);
    
    // String helpers.
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
