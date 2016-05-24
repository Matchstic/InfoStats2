//
//  IS2Private.h
//  InfoStats2
//
//  Created by Matt Clarke on 01/06/2015.
//
//

#import <Foundation/Foundation.h>

@interface IS2Private : NSObject {
    BOOL _screenState;
    
    // Timers used for IS1 legacy support.
    NSTimer *_batterytimer;
    NSTimer *_ramtimer;
}

+(NSBundle*)stringsBundle;
+(void)setupForTweakLoaded;
+(void)setupAfterSpringBoardLoaded;

+(instancetype)sharedInstance;
-(void)performBlockOnMainThread:(void (^)(void))callbackBlock;
-(void)setScreenOffState:(BOOL)screenState;
-(BOOL)getIsScreenOff;

+(NSString*)JSONescapedStringForString:(NSString*)input;

// Calendar

// Alarms

// Reminders
//+(void)presentCreateReminderPopup;


@end
