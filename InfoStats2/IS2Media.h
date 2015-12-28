/*
 * IS2Media.h
 * InfoStats2
 *
 * Created by Matt Clarke on 14/07/2015.
 *
*/

// TODO: Playlist support

#import <Foundation/Foundation.h>

/** IS2Media is used to access all media related data and functions. Whilst not everything available in terms of media controlling is found here, the contained methods are the most commonly used.
 */

@interface IS2Media : NSObject

/** @name Setup
 */

/** Sets a block to be called whenever music data changes. The identifier must be unique string; it is recommended to use reverse DNS notation, such as "com.foo.bar". It is highly advisable to use this function, as it will allow for your code to be automatically notified of any change in media data.
    @param identifier The identifier associated with your callback
    @param callbackBlock The block to call once data changes
*/

+(void)registerForNowPlayingNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock;

/** The inverse of registering for notifications. This must be called when your code is unloaded, else gremlins will squirm their way into your device.
 @param identifier The identifier associated with your callback
 */
+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier;

/*/** Requests new music data; data is updated a few milliseconds after any media state changes, so the callback block is called once updating completes.
    @param callbackBlock The block to call once refreshing completes
*/
//+(void)refreshMusicDataWithCallback:(void (^)(void))callbackBlock;*/


/** @name Functions */

/** Jumps to the next track. If no track is left in the queue, then this function will instead stop playing media.
 */
+(void)skipToNextTrack;

/** Jumps to the previous track. If no track was played beforehand, this function will then stop playing media.
 */
+(void)skipToPreviousTrack;

/** Toggles the playing state of the currently playing media.
 */
+(void)togglePlayPause;



/** @name Data Retrieval */

/** Gives the title for the currently play track, with an auto-translated string for if no media is playing.
 @return The current track's title, or translated "No media playing"
 */
+(NSString*)currentTrackTitle;

/** This function gives the artist name for the current track. If the user is playing a video via Safari, or another such application, then this value may be NULL since there may not be appropriate metadata value available.
 @return The current track's artist.
 @warning This function will return "" if no media has played since SpringBoard was last launched.
 */
+(NSString*)currentTrackArtist;

/** Gives the album for the current track. Please see currentTrackArtist for when a video is played.
 @return The current track's album
 @warning This function will return "" if no media has played since SpringBoard was last launched.
 */
+(NSString*)currentTrackAlbum;

/** Initializes an `UIImage' object with the current album artwork data.
 @return The current track's artwork image
 @warning This function will return a blank image if no media has played since SpringBoard was last launched.
 */
+(UIImage*)currentTrackArtwork;

/** Initializes a string with the current album artwork data as base64.
 @return The current track's artwork image as base64
 @warning This function will return "" if no media has played since SpringBoard was last launched.
 */
+(NSString*)currentTrackArtworkBase64;

/** Gives the current track's length, which measured in seconds.
 @return The current track's length
 @warning This function will return 0 if no media has played since SpringBoard was last launched.
 */
+(int)currentTrackLength;

/** Gives the current track number for the currently playing music track. For videos, this value is likely to be 0.
 @return The current track's number in its album
 @warning This function will return 0 if no media has played since SpringBoard was last launched.
 */
+(int)trackNumber;

/** Finds the amount of tracks in the album the current track is playing from. For videos, this value is likely to be 0.
 @return The number of available tracks in the current track's containing album
 @warning This function may return 0 if no media has played since SpringBoard was last launched.
 */
+(int)totalTrackCount;

/** A boolean specifying whether shuffle mode is currently enabled.
 @return The state of shuffle mode
 */
+(BOOL)shuffleEnabled;

/** A boolean specifying if media is currently being played via iTunes Radio.
 @return Whether the current track is being played from iTunes Radio
 */
+(BOOL)iTunesRadioPlaying;

/** A boolean specifying if media is playing or not.
 @return Whether media is playing or not
 */
+(BOOL)isPlaying;

@end
