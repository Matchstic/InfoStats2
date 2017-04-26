/* Cydget - open-source AwayView plugin multiplexer
 * Copyright (C) 2008-2011  Jay Freeman (saurik)
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

#include "yieldToSelector.h"

@implementation NSObject (CydgetYieldToSelector)

- (void) cydget$doNothing {
}

- (void) cydget$yieldToContext:(NSMutableArray *)context {
    NSAutoreleasePool *pool([[NSAutoreleasePool alloc] init]);

    SEL selector(reinterpret_cast<SEL>([[context objectAtIndex:0] pointerValue]));
    id object([[context objectAtIndex:1] nonretainedObjectValue]);
    volatile bool &stopped(*reinterpret_cast<bool *>([[context objectAtIndex:2] pointerValue]));

    /* XXX: deal with exceptions */
    id value([self performSelector:selector withObject:object]);

    NSMethodSignature *signature([self methodSignatureForSelector:selector]);
    [context removeAllObjects];
    if ([signature methodReturnLength] != 0 && value != nil)
        [context addObject:value];

    stopped = true;

    [self
        performSelectorOnMainThread:@selector(cydget$doNothing)
        withObject:nil
        waitUntilDone:NO
    ];

    [pool release];
}

- (id) cydget$yieldToSelector:(SEL)selector withObject:(id)object {
    volatile bool stopped(false);

    NSMutableArray *context([NSMutableArray arrayWithObjects:
        [NSValue valueWithPointer:selector],
        [NSValue valueWithNonretainedObject:object],
        [NSValue valueWithPointer:const_cast<bool *>(&stopped)],
    nil]);

    NSThread *thread([[[NSThread alloc]
        initWithTarget:self
        selector:@selector(cydget$yieldToContext:)
        object:context
    ] autorelease]);

    [thread start];

    NSRunLoop *loop([NSRunLoop currentRunLoop]);
    NSDate *future([NSDate distantFuture]);
    NSString *mode([loop currentMode] ?: NSDefaultRunLoopMode);

    while (!stopped && [loop runMode:mode beforeDate:future]);

    return [context count] == 0 ? nil : [context objectAtIndex:0];
}

- (id) cydget$yieldToSelector:(SEL)selector {
    return [self cydget$yieldToSelector:selector withObject:nil];
}

@end

