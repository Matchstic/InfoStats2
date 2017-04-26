//
//  CydgetURLProtocol.m
//  InfoStats2
//
//  Created by Matt Clarke on 05/04/2017.
//
//

#import "CydgetURLProtocol.h"
#import <UIKit/UIKit.h>

UIImage *_UIImageWithName(NSString *name);

@implementation CydgetURLProtocol

+ (BOOL) canInitWithRequest:(NSURLRequest *)request {
    NSURL *url = [request URL];
    if (url == nil)
        return NO;
    
    NSString *scheme = [[url scheme] lowercaseString];
    if (scheme == nil || ![scheme isEqualToString:@"cydget"])
        return NO;
    
    return YES;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void) _returnPNGWithImage:(UIImage *)icon forRequest:(NSURLRequest *)request {
    id<NSURLProtocolClient> client = [self client];
    if (icon == nil)
        [client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil]];
    else {
        NSData *data = UIImagePNGRepresentation(icon);
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:@"image/png" expectedContentLength:-1 textEncodingName:nil];
        [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocol:self didLoadData:data];
        [client URLProtocolDidFinishLoading:self];
    }
}

- (void) startLoading {
    id<NSURLProtocolClient> client = [self client];
    NSURLRequest *request = [self request];
    
    NSURL *url = [request URL];
    NSString *href = [url absoluteString];
    
    NSString *path = [href substringFromIndex:9];
    NSRange slash = [path rangeOfString:@"/"];
    
    NSString *command;
    if (slash.location == NSNotFound) {
        command = path;
        path = nil;
    } else {
        command = [path substringToIndex:slash.location];
        path = [path substringFromIndex:(slash.location + 1)];
    }
    
    if ([command isEqualToString:@"_UIImageWithName"]) {
        if (path == nil)
            goto fail;
        path = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        UIImage *icon = _UIImageWithName(path);
        [self _returnPNGWithImage:icon forRequest:request];
    } else fail: {
        [client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorResourceUnavailable userInfo:nil]];
    }
}

- (void) stopLoading {
}


@end
