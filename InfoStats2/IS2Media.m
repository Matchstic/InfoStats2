//
//  IS2Media.m
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import "IS2Media.h"
#import "IS2Extensions.h"
#import "IS2WorkaroundDictionary.h"
#include "MediaRemote.h"

#warning Media keys might break on iOS version changes.

static NSDictionary *data;
static IS2WorkaroundDictionary *mediaUpdateBlockQueue;

@interface NSData (Base64)
+ (NSData *)dataWithBase64EncodedString:(NSString *) string;
- (id)initWithBase64EncodedString:(NSString *) string;
- (NSString *)base64EncodingWithLineLength:(unsigned int) lineLength;

@end

static char encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

@implementation NSData (Base64)

+ (NSData *)dataWithBase64EncodedString:(NSString *) string {
    NSData *result = [[NSData alloc] initWithBase64EncodedString:string];
    return result;
}

- (id)initWithBase64EncodedString:(NSString *) string {
    NSMutableData *mutableData = nil;
    
    if( string ) {
        unsigned long ixtext = 0;
        unsigned long lentext = 0;
        unsigned char ch = 0;
        unsigned char inbuf[3], outbuf[4];
        short i = 0, ixinbuf = 0;
        BOOL flignore = NO;
        BOOL flendtext = NO;
        NSData *base64Data = nil;
        const unsigned char *base64Bytes = nil;
        
        // Convert the string to ASCII data.
        base64Data = [string dataUsingEncoding:NSASCIIStringEncoding];
        base64Bytes = [base64Data bytes];
        mutableData = [NSMutableData dataWithCapacity:[base64Data length]];
        lentext = [base64Data length];
        
        while( YES ) {
            if( ixtext >= lentext ) break;
            ch = base64Bytes[ixtext++];
            flignore = NO;
            
            if( ( ch >= 'A' ) && ( ch <= 'Z' ) ) ch = ch - 'A';
            else if( ( ch >= 'a' ) && ( ch <= 'z' ) ) ch = ch - 'a' + 26;
            else if( ( ch >= '0' ) && ( ch <= '9' ) ) ch = ch - '0' + 52;
            else if( ch == '+' ) ch = 62;
            else if( ch == '=' ) flendtext = YES;
            else if( ch == '/' ) ch = 63;
            else flignore = YES;
            
            if( ! flignore ) {
                short ctcharsinbuf = 3;
                BOOL flbreak = NO;
                
                if( flendtext ) {
                    if( ! ixinbuf ) break;
                    if( ( ixinbuf == 1 ) || ( ixinbuf == 2 ) ) ctcharsinbuf = 1;
                    else ctcharsinbuf = 2;
                    ixinbuf = 3;
                    flbreak = YES;
                }
                
                inbuf [ixinbuf++] = ch;
                
                if( ixinbuf == 4 ) {
                    ixinbuf = 0;
                    outbuf [0] = ( inbuf[0] << 2 ) | ( ( inbuf[1] & 0x30) >> 4 );
                    outbuf [1] = ( ( inbuf[1] & 0x0F ) << 4 ) | ( ( inbuf[2] & 0x3C ) >> 2 );
                    outbuf [2] = ( ( inbuf[2] & 0x03 ) << 6 ) | ( inbuf[3] & 0x3F );
                    
                    for( i = 0; i < ctcharsinbuf; i++ )
                        [mutableData appendBytes:&outbuf[i] length:1];
                }
                
                if( flbreak )  break;
            }
        }
    }
    
    self = [self initWithData:mutableData];
    return self;
}

- (NSString *)base64EncodingWithLineLength:(unsigned int) lineLength {
    const unsigned char	*bytes = [self bytes];
    NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
    unsigned long ixtext = 0;
    unsigned long lentext = [self length];
    long ctremaining = 0;
    unsigned char inbuf[3], outbuf[4];
    short i = 0;
    unsigned int charsonline = 0;
    short ctcopy = 0;
    unsigned long ix = 0;
    
    while( YES ) {
        ctremaining = lentext - ixtext;
        if( ctremaining <= 0 ) break;
        
        for( i = 0; i < 3; i++ ) {
            ix = ixtext + i;
            if( ix < lentext ) inbuf[i] = bytes[ix];
            else inbuf [i] = 0;
        }
        
        outbuf [0] = (inbuf [0] & 0xFC) >> 2;
        outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
        outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
        outbuf [3] = inbuf [2] & 0x3F;
        ctcopy = 4;
        
        switch( ctremaining ) {
            case 1: 
                ctcopy = 2; 
                break;
            case 2: 
                ctcopy = 3; 
                break;
        }
        
        for( i = 0; i < ctcopy; i++ )
            [result appendFormat:@"%c", encodingTable[outbuf[i]]];
        
        for( i = ctcopy; i < 4; i++ )
            [result appendFormat:@"%c",'='];
        
        ixtext += 3;
        charsonline += 4;
        
        if( lineLength > 0 ) {
            if (charsonline >= lineLength) {
                charsonline = 0;
                [result appendString:@"\n"];
            }
        }
    }
    
    return result;
}

@end

@implementation IS2Media

#pragma mark Private methods

+(void)nowPlayingDataDidUpdate {
    NSLog(@"[InfoStats2 | Media] :: Pulling data for media change");
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(CFDictionaryRef information) {
        data = (__bridge NSDictionary*)information;
        
        if (data) { // Seems to lead to crashes if data does not exist!
            //dispatch_async(dispatch_get_main_queue(), ^(void){
                // Let all our callbacks know we've got new data available.
                for (void (^block)() in [mediaUpdateBlockQueue allValues]) {
                    @try {
                        [[IS2Private sharedInstance] performSelectorOnMainThread:@selector(performBlockOnMainThread:) withObject:block waitUntilDone:YES];
                    } @catch (NSException *e) {
                        NSLog(@"[InfoStats2 | Media] :: Failed to update callback, with exception: %@", e);
                    } @catch (...) {
                        NSLog(@"[InfoStats2 | Media] :: Failed to update callback, with unknown exception");
                    }
                }
           // });
        }
    });
}

#pragma mark Public methods

+(void)registerForNowPlayingNotificationsWithIdentifier:(NSString*)identifier andCallback:(void (^)(void))callbackBlock {
    if (!mediaUpdateBlockQueue) {
        mediaUpdateBlockQueue = [IS2WorkaroundDictionary dictionary];
    }
    
    if (callbackBlock && identifier) {
        [mediaUpdateBlockQueue addObject:callbackBlock forKey:identifier];
    }
}

+(void)unregisterForNotificationsWithIdentifier:(NSString*)identifier {
    [mediaUpdateBlockQueue removeObjectForKey:identifier];
}

+(NSString*)currentTrackTitle {
    NSString *string = [IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoTitle"];
    
    if (!string) {
        return [[IS2Private stringsBundle] localizedStringForKey:@"NO_MEDIA" value:@"No media playing" table:nil];
    }
    
    return string;
}

+(NSString*)currentTrackArtist {
    NSString *string = [IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoArtist"];
    if (!string) string = @"";
    return string;
}

+(NSString*)currentTrackAlbum {
    NSString *string = [IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"];
    if (!string) string = @"";
    return string;
}

+(UIImage*)currentTrackArtwork {
    NSData *data = [IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoArtworkData"];
    return (data ? [UIImage imageWithData:data] : nil);
}

+(NSString*)currentTrackArtworkBase64 {
    UIImage *img = [IS2Media currentTrackArtwork];
    if (img) {
        @try {
            NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
            return [NSString stringWithFormat:@"data:image/jpeg;base64,%@", [imageData base64Encoding]];
        } @catch (NSException *e) {
            return @"data:image/jpeg;base64,";
        }
    } else {
        return @"data:image/jpeg;base64,";
    }
}

+(int)currentTrackLength {
    return [[IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoDuration"] intValue];
}

+(int)elapsedTrackLength {
    return [[IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoElapsedTime"] intValue];
}

+(BOOL)shuffleEnabled {
    return [[IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoShuffleMode"] intValue] != 0;
}

+(BOOL)iTunesRadioPlaying {
    return [[IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoSupportsIsLiked"] boolValue];
}

+(int)trackNumber {
    return [[IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoTrackNumber"] intValue];
}

+(int)totalTrackCount {
    return [[IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoTotalTrackCount"] intValue];
}

+(BOOL)isPlaying {
        return [[IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoPlaybackRate"] boolValue];
}

+(BOOL)hasMedia {
        return [[objc_getClass("SBMediaController") sharedInstance] hasTrack];
}

+(void)skipToNextTrack {
    MRMediaRemoteSendCommand(kMRNextTrack, 0);
}

+(void)skipToPreviousTrack {
    MRMediaRemoteSendCommand(kMRPreviousTrack, 0);
}

+(void)play {
    MRMediaRemoteSendCommand(kMRPlay, 0);
}

+(void)pause {
    MRMediaRemoteSendCommand(kMRPause, 0);
}

+(void)togglePlayPause {
    MRMediaRemoteSendCommand(kMRTogglePlayPause, 0);
}

+(id)getValueForKey:(NSString*)key {
    return [data objectForKey:key];
}

+(int)getVolume {
    return [[[objc_getClass("SBMediaController") sharedInstance] volume] intValue];
}

+(void)setVolume:(unsigned int) level {
    [[objc_getClass("SBMediaController") sharedInstance] setVolume:level];
}

@end
