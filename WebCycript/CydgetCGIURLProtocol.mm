//
//  CydgetCGIURLProtocol.m
//  InfoStats2
//
//  Created by Matt Clarke on 05/04/2017.
//
//

#import "CydgetCGIURLProtocol.h"

#define _assert(test) do \
    if (!(test)) { \
        NSLog(@"_assert(%d:%s)@%s:%u[%s]\n", errno, #test, __FILE__, __LINE__, __FUNCTION__); \
        exit(-1); \
    } \
    while (false)

#define _syscall(expr) \
     do if ((long) (expr) != -1) \
        break; \
     else switch (errno) { \
         case EINTR: \
            continue; \
         default: \
            _assert(false); \
    } while (true)

@implementation CydgetCGIURLProtocol

+ (BOOL) canInitWithRequest:(NSURLRequest *)request {
    NSURL *url = [request URL];
    if (url == nil)
        return NO;
    
    NSString *scheme = [[url scheme] lowercaseString];
    if (scheme == nil || ![scheme isEqualToString:@"cydget-cgi"])
        return NO;
    
    return YES;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (id) initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)response client:(id<NSURLProtocolClient>)client {
    if ((self = [super initWithRequest:request cachedResponse:response client:client]) != nil) {
        pid_ = -1;
    } return self;
}

- (void) startLoading {
    id<NSURLProtocolClient> client = [self client];
    NSURLRequest *request = [self request];
    NSURL *url = [request URL];
    
    NSString *path = [url path];
    if (path == nil) {
        [client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorResourceUnavailable userInfo:nil]];
        return;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        [client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil]];
        return;
    }
    
    int fds[2];
    _assert(pipe(fds) != -1);
    
    _assert(pid_ == -1);
    pid_ = fork();
    if (pid_ == -1) {
        _assert(close(fds[0]) != -1);
        _assert(close(fds[1]) != -1);
        [client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorResourceUnavailable userInfo:nil]];
        return;
    }
    
    if (pid_ == 0) {
        const char *script = [path UTF8String];
        
        setenv("GATEWAY_INTERFACE", "CGI/1.1", true);
        setenv("SCRIPT_FILENAME", script, true);
        NSString *query = [url query];
        if (query != nil)
            setenv("QUERY_STRING", [query UTF8String], true);
        
        _assert(dup2(fds[1], 1) != -1);
        _assert(close(fds[0]) != -1);
        _assert(close(fds[1]) != -1);
        
        execl(script, script, NULL);
        exit(1);
        _assert(false);
    }
    
    _assert(close(fds[1]) != -1);
    
    _assert(http_ == NULL);
    http_ = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, FALSE);
    CFHTTPMessageAppendBytes(http_, (const uint8_t *) "HTTP/1.1 200 OK\r\n", 17);
    
    _assert(handle_ == nil);
    handle_ = [[NSFileHandle alloc] initWithFileDescriptor:fds[0] closeOnDealloc:YES];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(onRead:)
     name:@"NSFileHandleReadCompletionNotification"
     object:handle_
     ];
    
    [handle_ readInBackgroundAndNotify];
}

- (void) onRead:(NSNotification *)notification {
    NSFileHandle *handle = [notification object];
    
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    size_t length = [data length];
    
    if (length > 0) {
        CFHTTPMessageAppendBytes(http_, reinterpret_cast<const UInt8 *>([data bytes]), length);
        [handle readInBackgroundAndNotify];
    } else {
        id<NSURLProtocolClient> client = [self client];
        
        CFStringRef mime = CFHTTPMessageCopyHeaderFieldValue(http_, CFSTR("Content-type"));
        if (mime == NULL)
            [client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil]];
        else {
            NSURLRequest *request = [self request];
            
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:(__bridge NSString *)mime expectedContentLength:-1 textEncodingName:nil];
            CFRelease(mime);
            
            [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            
            CFDataRef body = CFHTTPMessageCopyBody(http_);
            [client URLProtocol:self didLoadData:(__bridge NSData *)body];
            CFRelease(body);
            
            [client URLProtocolDidFinishLoading:self];
        }
        
        CFRelease(http_);
        http_ = NULL;
    }
}

- (void) stopLoading_ {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (handle_ != nil) {
        handle_ = nil;
    }
    
    if (pid_ != -1) {
        kill(pid_, SIGTERM);
        int status;
        _syscall(waitpid(pid_, &status, 0));
        pid_ = -1;
    }
}

- (void) stopLoading {
    [self
     performSelectorOnMainThread:@selector(stopLoading_)
     withObject:nil
     waitUntilDone:NO
     ];
}


@end
