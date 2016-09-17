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

#include "CydiaSubstrate.h"
#include <sys/sysctl.h>
#include <map>

_disused static unsigned trace_;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Declarations

static __attribute__((always_inline)) void initialiseInternalWebCycript();

extern "C" UIImage *_UIImageWithName(NSString *name);

typedef uint16_t UChar;
static bool iOS32, iOS4;

extern "C" void WebCycriptSetupView(WebView *webview) {
    NSLog(@"******** [InfoStats 2] :: Setup view %@", webview);
    if (void *handle = dlopen("/usr/lib/libcycript.dylib", RTLD_LAZY | RTLD_GLOBAL))
        if (void (*CYSetupContext)(JSGlobalContextRef) = reinterpret_cast<void (*)(JSGlobalContextRef)>(dlsym(handle, "CydgetSetupContext"))) {
            NSLog(@"HAS SETUP CONTEXT");
            WebFrame *frame([webview mainFrame]);
            JSGlobalContextRef context([frame globalContext]);
            @try {
                CYSetupContext(context);
            } @catch (NSException *e) {
                NSLog(@"*** CydgetSetupContext => %@", e);
            }
        }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

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
}; }

namespace JSC {
struct SourceCode {
    void *provider_;
    int start_;
    int end_;
    int line_;
}; }

namespace JSC {
union ScriptSourceCode {
    struct {
        JSC::SourceCode source_;
    } Old;
    struct {
        void *provider_;
        JSC::SourceCode source_;
    } New;
}; }

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
        //[*this autorelease];
    }

    operator CFStringRef() const {
        return value_;
    }

    operator NSString *() const {
        return (__bridge NSString *) value_;
    }
};

// String Helpers {{{
static const UChar *(*_ZNK7WebCore6String10charactersEv)(const WebCore::String *);
static const UChar *(*_ZN7WebCore6String29charactersWithNullTerminationEv)(const WebCore::String *);
static CFStringStruct (*_ZNK3WTF6String14createCFStringEv)(const WebCore::String *);
static unsigned (*_ZNK7WebCore6String6lengthEv)(const WebCore::String *);

static bool StringGet(const WebCore::String &string, const UChar *&data, size_t &length) {
    bool terminated;

    if (false) {
    } else if (_ZNK7WebCore6String10charactersEv != NULL) {
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
// }}}

// Script Compiler {{{
static void Log(const WebCore::String &string) {
#if 0
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

static bool cycript_;

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


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Hooks

// State Machine {{{

MSHook(bool, _ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE, const WebCore::String &mime) {
    NSLog(@"******** [InfoStats 2] :: isSupportedJavaScriptMIMEType");
    if (!StringEquals(mime, "text/cycript")) {
        cycript_ = false;
        return __ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE(mime);
    }
    
    static void *handle(dlopen("/usr/lib/libcycript.dylib", RTLD_LAZY | RTLD_GLOBAL));
    if (handle == NULL) {
        return false;
    }
    
    cycript_ = true;
    return true;
}
// }}}

static WebCore::String *string;

// iOS 2.x
MSHook(State, _ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i, void *_this, const WebCore::String &string, State state, const WebCore::String &url, int line) {
    Cycriptify(string);
    return __ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i(_this, string, state, url, line);
}

// iOS 3.x
MSHook(void, _ZN3JSC6Parser5parseEPNS_12JSGlobalDataEPiPNS_7UStringE, JSC::SourceCode **_this, JSC::JSGlobalData *global, int *line, JSC::UString *message) {
    /*if (cycript_) {
        JSC::SourceCode *source(_this[iOS32 ? 6 : 0]);
        const uint16_t *data(source->data());
        size_t size(source->length());

        if (Cycriptify(data, size)) {
            source->~SourceCode();
            // XXX: I actually don't have the original URL here: pants
            new (source) JSC::SourceCode(JSC::UStringSourceProvider::create(JSC::UString(data, size), "cycript://"), 1);
            free((void *) data);
        }
    }*/

    return __ZN3JSC6Parser5parseEPNS_12JSGlobalDataEPiPNS_7UStringE(_this, global, line, message);
}

// iOS 3.x cdata
MSHook(const WebCore::String &, _ZNK7WebCore4Node11textContentEb, void *_this, bool convert) {
    const WebCore::String &code(__ZNK7WebCore4Node11textContentEb(_this, convert));
    string = const_cast<WebCore::String *>(&code);
    Cycriptify(code);
    return code;
}

// iOS 4.x cdata
MSHook(void, _ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi, void *_this, const WebCore::String &source, const WebCore::KURL &url, int line) {
    Cycriptify(source);
    return __ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi(_this, source, url, line);
}

// iOS 4.x+5.0 @src=
MSHook(const WebCore::String &, _ZN7WebCore12CachedScript6scriptEv, void *_this) {
    const WebCore::String &script(__ZN7WebCore12CachedScript6scriptEv(_this));
    string = const_cast<WebCore::String *>(&script);
    return script;
}

// iOS 4.x @src=
MSHook(State, _ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE, void *_this, JSC::ScriptSourceCode &script, State state) {
    if (string != NULL) {
        JSC::SourceCode *source(iOS4 ? &script.New.source_ : &script.Old.source_);
        Cycriptify(*string, &source->end_);
        string = NULL;
    }

    return __ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE(_this, script, state);
}

// iOS 5.0 cdata
MSHook(void, _ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE, void *_this, const WebCore::String &source, const WebCore::KURL &url, void *position) {
    Cycriptify(source);
    return __ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE(_this, source, url, position);
}

// iOS 5.0 @src=
MSHook(void, _ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE, void *_this, void *position, int legacy) {
    string = NULL;
    return __ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE(_this, position, legacy);
}

void (*$_ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE)(void *_this, int legacy);

// iOS 5.0 @src=
MSHook(void, _ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE, void *_this, JSC::ScriptSourceCode &script) {
    if (string != NULL) {
        JSC::SourceCode *source(&script.New.source_);
        $_ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE(_this, 0);
        Cycriptify(*string, &source->end_);
        string = NULL;
    }

    return __ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE(_this, script);
}

// iOS 6.0 cdata
MSHook(void, _ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE, void *_this, const WebCore::String &source, const WebCore::KURL &url, void *position) {
    Cycriptify(source);
    return __ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE(_this, source, url, position);
}

// iOS 6.0 @src=
MSHook(void, _ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE, void *_this, void *position, int legacy) {
    string = NULL;
    return __ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE(_this, position, legacy);
}

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
}; }

typedef std::map<std::string, BOOL (*)()> StyleMap_;
static StyleMap_ styles_;

MSHook(bool, _ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE, WebCore::MediaQueryEvaluator *_this, WebCore::String &query) {
    Log(query);
    for (StyleMap_::const_iterator style(styles_.begin()); style != styles_.end(); ++style)
        if (StringEquals(query, style->first.c_str()))
            return style->second();
    return __ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE(_this, query);
}

MSHook(void *, _ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE, WebCore::MediaQueryExp *_this, WebCore::String &query, WebCore::CSSParserValueList *values) {
    Log(query);
    void *value(__ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE(_this, query, values));
    if (!_this->valid_)
        for (StyleMap_::const_iterator style(styles_.begin()); style != styles_.end(); ++style)
            if (StringEquals(query, style->first.c_str()))
                _this->valid_ = true;
    return value;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <typename Type_>
static void dlset(Type_ &function, const char *name) {
    function = reinterpret_cast<Type_>(dlsym(RTLD_DEFAULT, name));
}

#define msset(function, handle) \
    MSHookSymbol(function, "_" #function, handle)

static __attribute__((always_inline)) void initialiseInternalWebCycript() {
    iOS4 = kCFCoreFoundationVersionNumber >= 550.32;
    iOS32 = !iOS4 && kCFCoreFoundationVersionNumber >= 478.61;
    
    NSLog(@"***************************************");

    int maxproc;
    size_t size(sizeof(maxproc));
    if (sysctlbyname("kern.maxproc", &maxproc, &size, NULL, 0) == -1)
        NSLog(@"sysctlbyname(\"kern.maxproc\", ?)");
    else if (maxproc < 72) {
        maxproc = 72;
        if (sysctlbyname("kern.maxproc", NULL, NULL, &maxproc, sizeof(maxproc)) == -1)
            NSLog(@"sysctlbyname(\"kern.maxproc\", #)");
    }
    
    NSLog(@"maxproc == %d", maxproc);

    MSImageRef JavaScriptCore(NULL);
    if (JavaScriptCore == NULL)
        JavaScriptCore = MSGetImageByName("/System/Library/Frameworks/JavaScriptCore.framework/JavaScriptCore");
    if (JavaScriptCore == NULL)
        JavaScriptCore = MSGetImageByName("/System/Library/PrivateFrameworks/JavaScriptCore.framework/JavaScriptCore");
    
    NSLog(@"JavaScriptCore == %p", JavaScriptCore);

    MSImageRef WebCore(MSGetImageByName("/System/Library/PrivateFrameworks/WebCore.framework/WebCore"));
    
    NSLog(@"WebCore == %p", WebCore);
    
    /*
     * It seems the issue right now is that the hooks simply do not get applied. 
     *
     * My assumption is that WebCore no longer has these symbols, and so dlsym will return NULL for them.
     * Of course, this is a humungous pain in the ass, since it works just fine in the WebCycript package.
     * Weird, as usual.
    */

    if (!iOS4) {
        void (*_ZN3JSC6Parser5parseEPNS_12JSGlobalDataEPiPNS_7UStringE)(JSC::SourceCode **, JSC::JSGlobalData *, int *, JSC::UString *);
        dlset(_ZN3JSC6Parser5parseEPNS_12JSGlobalDataEPiPNS_7UStringE, "_ZN3JSC6Parser5parseEPNS_12JSGlobalDataEPiPNS_7UStringE");
        
        NSLog(@"Parser::parse == %p", _ZN3JSC6Parser5parseEPNS_12JSGlobalDataEPiPNS_7UStringE);
        
        if (_ZN3JSC6Parser5parseEPNS_12JSGlobalDataEPiPNS_7UStringE != NULL)
            MSHookFunction(_ZN3JSC6Parser5parseEPNS_12JSGlobalDataEPiPNS_7UStringE, MSHake(_ZN3JSC6Parser5parseEPNS_12JSGlobalDataEPiPNS_7UStringE));
    }

    bool (*_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE)(const WebCore::String &) = NULL;
    if (_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE == NULL)
        MSHookSymbol(_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE, "__ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE", (void*)WebCore);
    if (_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE == NULL)
        MSHookSymbol(_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE, "__ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKN3WTF6StringE", (void*)WebCore);
    
    NSLog(@"WebCore::MIMETypeRegistry::isSupportedJavaScriptMIMEType == %p", _ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE);
    
    if (_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE != NULL)
        MSHookFunction(_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE, MSHake(_ZN7WebCore16MIMETypeRegistry29isSupportedJavaScriptMIMETypeERKNS_6StringE));

    void (*_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi)(void *, const WebCore::String &, const WebCore::KURL &, int) = NULL;
    if (_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi == NULL)
        MSHookSymbol(_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi, "__ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi", (void*)WebCore);
    
    NSLog(@"WebCore::ScriptSourceCode == %p", _ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi);
    
    if (_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi != NULL)
        MSHookFunction(_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi, MSHake(_ZN7WebCore16ScriptSourceCodeC2ERKNS_6StringERKNS_4KURLEi));

    if (!iOS4) {
        const WebCore::String &(*_ZNK7WebCore4Node11textContentEb)(void *, bool) = NULL;
        if (_ZNK7WebCore4Node11textContentEb == NULL)
            MSHookSymbol(_ZNK7WebCore4Node11textContentEb, "__ZNK7WebCore4Node11textContentEb", (void*)WebCore);
        
        NSLog(@"WebCore::Node::textContent == %p", _ZNK7WebCore4Node11textContentEb);
        
        if (_ZNK7WebCore4Node11textContentEb != NULL)
            MSHookFunction(_ZNK7WebCore4Node11textContentEb, MSHake(_ZNK7WebCore4Node11textContentEb));
    }

    const WebCore::String &(*_ZN7WebCore12CachedScript6scriptEv)(void *) = NULL;
    if (_ZN7WebCore12CachedScript6scriptEv == NULL)
        MSHookSymbol(_ZN7WebCore12CachedScript6scriptEv, "__ZN7WebCore12CachedScript6scriptEv", (void*)WebCore);
    
    NSLog(@"WebCore::CachedScript::script == %p", _ZN7WebCore12CachedScript6scriptEv);
    
    if (_ZN7WebCore12CachedScript6scriptEv != NULL)
        MSHookFunction(_ZN7WebCore12CachedScript6scriptEv, MSHake(_ZN7WebCore12CachedScript6scriptEv));

    State (*_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i)(void *, const WebCore::String &, State, const WebCore::String &, int) = NULL;
    if (_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i == NULL)
        MSHookSymbol(_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i, "__ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i", (void*)WebCore);
    
    NSLog(@"WebCore::HTMLTokenizer::scriptExecution(String, State) == %p", _ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i);
    
    if (_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i != NULL)
        MSHookFunction(_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i, MSHake(_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_6StringENS0_5StateES3_i));

    State (*_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE)(void *, JSC::ScriptSourceCode &, State) = NULL;
    if (_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE == NULL)
        MSHookSymbol(_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE, "__ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE", (void*)WebCore);
    
    NSLog(@"WebCore::HTMLTokenizer::scriptExecution(ScriptSourceCode, State) == %p", _ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE);
    
    if (_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE != NULL)
        MSHookFunction(_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE, MSHake(_ZN7WebCore13HTMLTokenizer15scriptExecutionERKNS_16ScriptSourceCodeENS0_5StateE));

    void (*_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE)(void *, const WebCore::String &, const WebCore::KURL &, void *);
    msset(_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE, (void*)WebCore);
    
    NSLog(@"WebCore::ScriptSourceCode(String, TextPosition, OneBasedNumber) == %p", _ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE);
    
    if (_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE != NULL)
        MSHookFunction(_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE, MSHake(_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionINS1_14OneBasedNumberEEE));

    void (*_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE)(void *, const WebCore::String &, const WebCore::KURL &, void *);
    msset(_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE, (void*)WebCore);
    if (_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE == NULL)
        MSHookSymbol(_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE, "__ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_3URLERKNS1_12TextPositionE", (void*)WebCore);
    
    NSLog(@"WebCore::ScriptSourceCode(String, TextPosition) == %p", _ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE);
    
    if (_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE != NULL)
        MSHookFunction(_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE, MSHake(_ZN7WebCore16ScriptSourceCodeC2ERKN3WTF6StringERKNS_4KURLERKNS1_12TextPositionE));

    void (*_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE)(void *, void *, int);
    msset(_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE, (void*)WebCore);
    
    NSLog(@"WebCore::ScriptElement::prepareScript(TextPosition, OneBasedNumber, LegacyTypeSupport) == %p", _ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE);
    
    if (_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE != NULL)
        MSHookFunction(_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE, MSHake(_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionINS1_14OneBasedNumberEEENS0_17LegacyTypeSupportE));

    void (*_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE)(void *, void *, int);
    msset(_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE, (void*)WebCore);
    
    NSLog(@"WebCore::ScriptElement::prepareScript(TextPosition, LegacyTypeSupport) == %p", _ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE);
    
    if (_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE != NULL)
        MSHookFunction(_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE, MSHake(_ZN7WebCore13ScriptElement13prepareScriptERKN3WTF12TextPositionENS0_17LegacyTypeSupportE));

    // XXX: Why is this function not paired with a hook?
    MSHookSymbol($_ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE, "__ZNK7WebCore13ScriptElement21isScriptTypeSupportedENS0_17LegacyTypeSupportE", (void*)WebCore);

    void (*_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE)(void *, JSC::ScriptSourceCode &);
    msset(_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE, (void*)WebCore);
    
    NSLog(@"WebCore::ScriptElement::executeScript(ScriptSourceCode) == %p", _ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE);
    
    if (_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE != NULL)
        MSHookFunction(_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE, MSHake(_ZN7WebCore13ScriptElement13executeScriptERKNS_16ScriptSourceCodeE));

    if (_ZN7WebCore6String6appendEPKtj == NULL)
        MSHookSymbol(_ZN7WebCore6String6appendEPKtj, "__ZN7WebCore6String6appendEPKtj", (void*)WebCore);
    if (_ZN7WebCore6String6appendEPKtj == NULL)
        msset(_ZN7WebCore6String6appendEPKtj, (void*)JavaScriptCore);
    if (_ZN7WebCore6String6appendEPKtj == NULL)
        MSHookSymbol(_ZN7WebCore6String6appendEPKtj, "__ZN3WTF6String6appendEPKtj", (void*)JavaScriptCore);
    
    NSLog(@"WebCore::String::append == %p", _ZN7WebCore6String6appendEPKtj);

    if (_ZN7WebCore6String8truncateEj == NULL)
        MSHookSymbol(_ZN7WebCore6String8truncateEj, "__ZN7WebCore6String8truncateEj", (void*)WebCore);
    if (_ZN7WebCore6String8truncateEj == NULL)
        msset(_ZN7WebCore6String8truncateEj, (void*)JavaScriptCore);
    if (_ZN7WebCore6String8truncateEj == NULL)
        MSHookSymbol(_ZN7WebCore6String8truncateEj, "__ZN3WTF6String8truncateEj", (void*)JavaScriptCore);
    
    NSLog(@"WebCore::String::truncate == %p", _ZN7WebCore6String8truncateEj);

    msset(_ZNK7WebCore6String10charactersEv, (void*)WebCore);

    msset(_ZN7WebCore6String29charactersWithNullTerminationEv, (void*)JavaScriptCore);
    if (_ZN7WebCore6String29charactersWithNullTerminationEv == NULL)
        MSHookSymbol(_ZN7WebCore6String29charactersWithNullTerminationEv, "__ZN3WTF6String29charactersWithNullTerminationEv", (void*)JavaScriptCore);
    
    NSLog(@"WebCore::String::charactersWithNullTermination == %p", _ZN7WebCore6String29charactersWithNullTerminationEv);

    msset(_ZNK3WTF6String14createCFStringEv, (void*)JavaScriptCore);

    msset(_ZNK7WebCore6String6lengthEv, (void*)WebCore);

    bool (*_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE)(WebCore::MediaQueryEvaluator *, WebCore::String &);
    msset(_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE, (void*)WebCore);
    
    NSLog(@"WebCore::MediaQueryEvaluator::eval(MediaQuery) == %p", _ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE);
    
    if (_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE != NULL)
        MSHookFunction(_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE, MSHake(_ZNK7WebCore19MediaQueryEvaluator4evalEPKNS_13MediaQueryExpE));

    void *(*_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE)(WebCore::MediaQueryExp *, WebCore::String &, WebCore::CSSParserValueList *);
    msset(_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE, (void*)WebCore);
    
    NSLog(@"WebCore::MediaQueryExp(AtomicString, ParserValueList) == %p", _ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE);
    
    if (_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE != NULL)
        MSHookFunction(_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE, MSHake(_ZN7WebCore13MediaQueryExpC2ERKN3WTF12AtomicStringEPNS_18CSSParserValueListE));
    
    NSLog(@"***************************************");
}

MSClassHook(WebView)
MSMetaClassHook(WebView)
