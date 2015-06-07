//
//  CIWExtensions.h
//  CycriptIniWidgets
//
//  Created by Matt Clarke on 01/06/2015.
//
//

#import <Foundation/Foundation.h>

@interface CIWExtensions : NSObject

// Battery
+(int)batteryPercent;
+(NSString*)batteryState; // This is pre-translated for you
+(int)batteryStateAsInteger; // Shouldn't really need this, but it's available

// RAM - all values in MB
+(int)ramFree; // Free RAM = free + inactive (inactive is treated as free by iOS)
+(int)ramUsed;
+(int)ramAvailable;

// Wireless etc
+(int)phoneSignalBars;
+(int)phoneSignalRSSI;
+(NSString*)phoneCarrier;
+(BOOL)wifiEnabled;
+(int)wifiSignalBars;
+(int)wifiSignalRSSI;
+(NSString*)wifiName;
+(BOOL)airplaneModeEnabled;

// Weather
+(int)currentTemperature;
+(int)currentCondition;
+(NSString*)currentConditionAsString;
+(int)highForCurrentDay;
+(int)lowForCurrentDay;
+(int)currentWindSpeed;
+(NSString*)currentLocation;
+(NSArray*)hourlyForecastsForCurrentLocation;
+(NSArray*)dayForecastsForCurrentLocation;
+(BOOL)isWeatherUpdating;
+(void)updateWeatherWithCallback:(void (^)(void))callbackBlock;

// Calendar

// Alarms

// Reminders
+(void)presentCreateReminderPopup;

// Music
+(NSString*)currentTrackTitle;
+(NSString*)currentTrackArtist;
+(NSString*)currentTrackAlbum;
+(UIImage*)currentTrackArtwork;
+(int)currentTrackLength;
+(BOOL)shuffleEnabled;
+(BOOL)iTunesRadioPlaying;
+(void)skipToNextTrack;
+(void)skipToPreviousTrack;

// System utilities
+(void)takeScreenshot;
+(void)lockDevice;
+(void)openSwitcher;
+(void)openApplication:(NSString*)bundleIdentifier;


@end
