//
//  CydgetCGIURLProtocol.h
//  InfoStats2
//
//  Created by Matt Clarke on 05/04/2017.
//
//

#import <Foundation/Foundation.h>

@interface CydgetCGIURLProtocol : NSURLProtocol {
    pid_t pid_;
    CFHTTPMessageRef http_;
    NSFileHandle *handle_;
}

@end
