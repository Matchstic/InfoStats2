//
//  IS2Private.h
//  InfoStats2
//
//  Created by Matt Clarke on 01/06/2015.
//
//

#import <Foundation/Foundation.h>

@interface IS2Private : NSObject

+(NSBundle*)stringsBundle;
+(void)setupForTweakLoaded;
+(void)setupAfterSpringBoardLoaded;

+(NSString*)JSONescapedStringForString:(NSString*)input;

// Calendar

// Alarms

// Reminders
//+(void)presentCreateReminderPopup;


@end
