//
//  IS2Media.m
//  InfoStats2
//
//  Created by Matt Clarke on 14/07/2015.
//
//

#import "IS2Media.h"
#import "IS2Extensions.h"
#include "MediaRemote.h"

static NSDictionary *data;

@implementation IS2Media

+(NSString*)currentTrackTitle {
    NSString *string = [IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoTitle"];
    
    if (!string) {
        return [[IS2Private stringsBundle] localizedStringForKey:@"NO_MEDIA" value:@"No media playing" table:nil];
    }
    
    return string;
}

+(NSString*)currentTrackArtist {
    return [IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoArtist"];
}

+(NSString*)currentTrackAlbum {
    return [IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"];
}

+(UIImage*)currentTrackArtwork {
    NSData *data = [IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoArtworkData"];
    return [UIImage imageWithData:data];
}

+(int)currentTrackLength {
    return [[IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoDuration"] intValue];
}

+(int)elapsedTrackLength {
    return [[IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoElapsedTime"] intValue];
}

+(BOOL)shuffleEnabled {
    return [[IS2Media getValueForKey:@"kMRMediaRemoteNowPlayingInfoShuffleMode"] boolValue];
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
    Boolean __block isPlaying;
    
    MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean playing) {
        isPlaying = playing;
    });
    
    return isPlaying;
}

+(void)skipToNextTrack {
    MRMediaRemoteSendCommand(kMRNextTrack, 0);
}

+(void)skipToPreviousTrack {
    MRMediaRemoteSendCommand(kMRPreviousTrack, 0);
}

+(void)togglePlayPause {
    MRMediaRemoteSendCommand(kMRTogglePlayPause, 0);
}

+(void)refreshMusicDataWithCallback:(void (^)(void))callbackBlock {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        data = (__bridge NSDictionary*)information;
        
        NSLog(@"DATA HAS BEEN UPDATED");
        
        [callbackBlock invoke];
        
        NSLog(@"CALLBACK FINISHED");
    });
}

+(id)getValueForKey:(NSString*)key {
    return [data objectForKey:key];
}

@end
