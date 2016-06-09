//
//  IS2Calendar.h
//  InfoStats2
//
//  Created by Matt Clarke on 23/07/2015.
//
//

#import <Foundation/Foundation.h>

/** IS2Calendar is used to create, read, and modify events stored in the user's calendar; all changes will be reflected immediately in Calendar.app. For those using this API in JavaScript, all timestamps utilised are in milliseconds, to allow interoperability with <code>Date</code> objects.
 
 Please note that this class is not yet complete; more methods relating to modifying events will need to be added.
 */
@interface IS2Calendar : NSObject

/** @name Setup
 */

/** Sets a block to be called whenever the user's calendar changes, such as when the Calendar app adds or modifies an event. The identifier must be unique string; it is recommended to use reverse DNS notation, such as "com.foo.bar".
@param identifier The identifier associated with your callback
@param callbackBlock The block to call once data changes
*/
+(void)registerForCalendarNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock;

/** The inverse of registering for notifications. This must be called when your code is unloaded!
 @param identifier The identifier associated with your callback
 */
+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier;

/** @name Creating new events
 */

/** Adds a new calendar entry to the device. This method is for usage by JavaScript developers; the timestamp is assumed to be in terms of milliseconds, such as that provided by <code>Date.now()</code>.
 @param title Title of the new calendar event.
 @param location Location of the event - this can be null.
 @param startTime Start time of the event, as a timestamp in milliseconds
 @param endTime End time of the event, again as a timestamp in milliseconds
 @param isAllDay Defines whether the new event is to last all day - ensure that startTime is 00:00 of the day specified
 */
+(void)addCalendarEntryWithTitle:(NSString*)title location:(NSString*)location startTimeAsTimestamp:(time_t)startTime andEndTimeAsTimestamp:(time_t)endTime isAllDayEvent:(BOOL)isAllDay;

/** Adds a new calendar entry to the device; this is intended for usage via Objective-C.
 @param title Title of the new calendar event.
 @param location Location of the event - this can be null.
 @param startTime Start time of the event
 @param endTime End time of the event
 @param isAllDay Defines whether the new event is to last all day - ensure that startTime is 00:00 of the day specified
 */
+(void)addCalendarEntryWithTitle:(NSString*)title location:(NSString*)location startTime:(NSDate*)startTime andEndTime:(NSDate*)endTime isAllDayEvent:(BOOL)isAllDay;

/** Adds a new calendar entry to the device. The start time of the event is assumed to be the time at which the method is called, and the end time is an hour afterwards.
 @param title Title of the new calendar event.
 @param location Location of the event - this can be null.
 */
+(void)addCalendarEntryWithTitle:(NSString *)title andLocation:(NSString *)location;

/** @name Retrieving events
 */

/** A JSON array representing calendar events between the two timestamps specified. This is sourced from all available calendars defined by the user.
 @param startTime Start time of the event, as a timestamp in milliseconds
 @param endTime End time of the event, again as a timestamp in milliseconds
 @return JSON representation of the requested calendar events, in the form:<code><br/>
 [<br/>
 &emsp;{<br/>
 &emsp;&emsp;"title": "Example event",<br/>
 &emsp;&emsp;"location": "Example location",<br/>
 &emsp;&emsp;"allDay": 0, (Boolean defining whether the current event is to run all day)<br/>
 &emsp;&emsp;"startTimeTimestamp": 1451528264000, (Timestamp in milliseconds)<br/>
 &emsp;&emsp;"endTimeTimestamp": 1451692799000, (Timestamp in milliseconds)<br/>
 &emsp;&emsp;"associatedCalendarName": "Default",<br/>
 &emsp;&emsp;"associatedCalendarHexColor": "#C6F4D2"<br/>
 &emsp;},<br/>
 &emsp;{<br/>
 &emsp;&emsp;...<br/>
 &emsp;}<br/>
 ]<br/></code>
 */
+(NSString*)calendarEntriesJSONBetweenStartTimeAsTimestamp:(time_t)startTime andEndTimeAsTimestamp:(time_t)endTime;

/** Gives an array of calendar events between the dates specified. This is sourced from all available calendars defined by the user.
 @param startTime Start time of the event
 @param endTime End time of the event
 @return An array of <code>EKEvent</code> objects representing calendar entries
 */
+(NSArray*)calendarEntriesBetweenStartTime:(NSDate*)startTime andEndTime:(NSDate*)endTime;

@end
