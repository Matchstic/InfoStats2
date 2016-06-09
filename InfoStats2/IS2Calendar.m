//
//  IS2Calendar.m
//  InfoStats2
//
//  Created by Matt Clarke on 23/07/2015.
//
//

#import "IS2Calendar.h"
#import <EventKit/EventKit.h>
#import <objc/runtime.h>
#import "IS2Extensions.h"
#import "IS2WorkaroundDictionary.h"
#import "IS2Extensions.h"

static EKEventStore *store;
static BOOL isAuthorised;
static IS2Calendar *sharedInstance;
static IS2WorkaroundDictionary *calendarUpdateBlockQueue;

@interface EKCalendar (Private)
@property (nonatomic, readonly) NSString *calendarIdentifier;
@end

@interface IS2Calendar ()
@property(assign) dispatch_source_t source;
@end

@implementation IS2Calendar

#pragma Private methods

+(NSString *)hexStringFromColor:(CGColorRef)color {
    const CGFloat *components = CGColorGetComponents(color);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

+(time_t)timestampToSeconds:(time_t)input {
    return input / 1000;
}

+(void)setupAfterTweakLoad {
    store = [[EKEventStore alloc] init];
    isAuthorised = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized;
    
    [[IS2Calendar sharedInstance] setupNotificationMonitoring];
}

+(instancetype)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[IS2Calendar alloc] init];
    }
    
    return sharedInstance;
}

-(void)setupNotificationMonitoring {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarUpdateNotificationRecieved:) name:@"EKEventStoreChangedNotification" object:store];
    [self monitorPath:@"/var/mobile/Library/Preferences/com.apple.mobilecal.plist"];
}

-(void)calendarUpdateNotificationRecieved:(NSNotification*)notification {
    if (store == NULL) { // Handle if the event store becomes NULL for some reason.
        store = [[EKEventStore alloc] init];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        // Let all our callbacks know we've got new data available.
        for (void (^block)() in [calendarUpdateBlockQueue allValues]) {
            @try {
                block();
            } @catch (NSException *e) {
                NSLog(@"*** [InfoStats2 | Calendar] :: Failed to update a callback, with exception: %@", e);
            }
        }
    });
}

// This allows us to fire off a callback when the user changes which calendars to display in-app.
-(void)monitorPath:(NSString*)path {
    
    int descriptor = open([path fileSystemRepresentation], O_EVTONLY);
    if (descriptor < 0) {
        return;
    }
    
    __block typeof(self) blockSelf = self;
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, descriptor,                                                  DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE, dispatch_get_global_queue(0, 0));
    
    dispatch_source_set_event_handler(_source, ^{
        unsigned long flags = dispatch_source_get_data(_source);
        
        if (flags & DISPATCH_VNODE_DELETE) {
           [blockSelf monitorPath:path];
        } else {
            // Update our data.
            [self calendarUpdateNotificationRecieved:nil];
        }
    });
    
    dispatch_source_set_cancel_handler(_source, ^(void) {
        close(descriptor);
    });
    
    dispatch_resume(_source);
}

-(void)dealloc {
    if (_source) {
        dispatch_source_cancel(_source);
        dispatch_release(_source);
        _source = NULL;
    }
}

#pragma mark Public methods

+(void)registerForCalendarNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock {
    if (!calendarUpdateBlockQueue) {
        calendarUpdateBlockQueue = [IS2WorkaroundDictionary dictionary];
    }
    
    if (callbackBlock && identifier) {
        [calendarUpdateBlockQueue addObject:callbackBlock forKey:identifier];
    }
}

+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier {
    [calendarUpdateBlockQueue removeObjectForKey:identifier];
}

+(void)addCalendarEntryWithTitle:(NSString*)title location:(NSString*)location startTimeAsTimestamp:(time_t)startTime andEndTimeAsTimestamp:(time_t)endTime isAllDayEvent:(BOOL)isAllDay {
    NSDate *start = [NSDate dateWithTimeIntervalSince1970:[IS2Calendar timestampToSeconds:startTime]];
    NSDate *end = [NSDate dateWithTimeIntervalSince1970:[IS2Calendar timestampToSeconds:endTime]];
    
    [IS2Calendar addCalendarEntryWithTitle:title location:location startTime:start andEndTime:end isAllDayEvent:isAllDay];
}

+(void)addCalendarEntryWithTitle:(NSString *)title andLocation:(NSString *)location {
    NSDate *start = [NSDate date];
    NSDate *end = [NSDate dateWithTimeInterval:3600 sinceDate:start]; // Hour from last date
    
    [IS2Calendar addCalendarEntryWithTitle:title location:location startTime:start andEndTime:end isAllDayEvent:NO];
}

+(void)addCalendarEntryWithTitle:(NSString*)title location:(NSString*)location startTime:(NSDate*)startTime andEndTime:(NSDate*)endTime isAllDayEvent:(BOOL)isAllDay {
    
    EKEvent *newEvent = [EKEvent eventWithEventStore:store];
    newEvent.calendar = [store defaultCalendarForNewEvents];
    newEvent.title = title;
    newEvent.location = location;
    newEvent.startDate = startTime;
    newEvent.endDate = endTime;
    newEvent.allDay = isAllDay;
    
    NSError *error;
    [store saveEvent:newEvent span:EKSpanThisEvent commit:YES error:&error];
    
    if (error) {
        NSLog(@"*** [InfoStats2 | Calendar] :: Failed to add new event with reason: %@", error.localizedDescription);
    }
}

+(NSString*)calendarEntriesJSONBetweenStartTimeAsTimestamp:(time_t)startTime andEndTimeAsTimestamp:(time_t)endTime {
    NSMutableString *string = [@"[" mutableCopy];
    
    NSArray *entries = [IS2Calendar calendarEntriesBetweenStartTime:[NSDate dateWithTimeIntervalSince1970:[IS2Calendar timestampToSeconds:startTime]] andEndTime:[NSDate dateWithTimeIntervalSince1970:[IS2Calendar timestampToSeconds:endTime]]];
    
    int i = 0;
    for (EKEvent *event in entries) {
        i++;
        [string appendString:@"{"];
        
        [string appendFormat:@"\"title\":\"%@\",", [IS2Private JSONescapedStringForString:event.title]];
        [string appendFormat:@"\"location\":\"%@\",", [IS2Private JSONescapedStringForString:event.location]];
        [string appendFormat:@"\"allDay\":%d,", event.allDay];
        [string appendFormat:@"\"startTimeTimestamp\":%ld,", (time_t)event.startDate.timeIntervalSince1970 * 1000];
        [string appendFormat:@"\"endTimeTimestamp\":%ld,", (time_t)event.endDate.timeIntervalSince1970 * 1000];
        [string appendFormat:@"\"associatedCalendarName\":\"%@\",", [IS2Private JSONescapedStringForString:event.calendar.title]];
        [string appendFormat:@"\"associatedCalendarHexColor\":\"%@\"", [IS2Calendar hexStringFromColor:event.calendar.CGColor]];
        
        [string appendFormat:@"}%@", (i == entries.count ? @"" : @",")];
    }
    
    [string appendString:@"]"];
    
    return string;
}

+(NSArray*)calendarEntriesBetweenStartTime:(NSDate*)startTime andEndTime:(NSDate*)endTime {
    // Search all calendars
    NSMutableArray *searchableCalendars = [[store calendarsForEntityType:EKEntityTypeEvent] mutableCopy];
    
    NSPredicate *predicate = [store predicateForEventsWithStartDate:startTime endDate:endTime calendars:searchableCalendars];
    
    // Fetch all events that match the predicate
    NSMutableArray *events = [NSMutableArray arrayWithArray:[store eventsMatchingPredicate:predicate]];
    
    // Grab prefs for disabled calendars
    CFPreferencesAppSynchronize(CFSTR("com.apple.mobilecal"));
    
    NSDictionary *settings = (__bridge NSDictionary *)CFPreferencesCopyMultiple(CFPreferencesCopyKeyList(CFSTR("com.apple.mobilecal"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost), CFSTR("com.apple.mobilecal"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSArray *deselected = settings[@"LastDeselectedCalendars"];
    
    for (EKEvent *event in [events copy]) {
        if ([deselected containsObject:event.calendar.calendarIdentifier]) {
            [events removeObject:event];
        }
    }
    
    return events;
}

@end
