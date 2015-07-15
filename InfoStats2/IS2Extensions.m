//
//  IS2Private.m
//  InfoStats2
//
//  Created by Matt Clarke on 01/06/2015.
//

#import "IS2Extensions.h"

static NSBundle *bundle; // strings bundle.

@implementation IS2Private

#pragma mark Internal

+(NSBundle*)stringsBundle {
    if (!bundle) {
        bundle = [NSBundle bundleWithPath:@"/Library/Application Support/InfoStats2/Localisable.bundle"];
    }
    
    return bundle;
}

@end
