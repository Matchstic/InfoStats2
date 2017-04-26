/*
 * All data present in IS2Media can be accessed like so:
 * 
 * var thingYouWant = IS2Media.<insert_thing_here>();
 *
 * You will need to setup IS2Media with a function to call whenever data is updated by InfoStats 2,
 * along with a second optional function to call when media changes position in playback.
 * To do so, in the first function that you've defined at either <body onload="firstFunction()"> or at
 * the bottom of your <body> tag before </body>, you'll want to call the following function:
 *
 * IS2Media.init(<function_to_call_when_data_updates>, <function_to_call_when_playback_changes>);
 *
 * Where <function_to_call_when_data_updates> and <function_to_call_when_playback_changes> are typed without 
 * the usual () following it.
 *
 * As stated, the second function is optional, so if you don't need to be notified when media changes the 
 * amount of time that has elapsed on the track, pass null here.
 *
 * For further documentation on the data provided here, make sure to check the IS2 documentation found at
 * http://incendo.ws/projects/InfoStats2/Classes/IS2Media.html
 * Each IS2 function used in this script is documented there.
*/

var IS2Media = {
  // Setup
  init: function(mediaChangedCallback, timeElapsedChangedCallback) {
    [IS2Media registerForNowPlayingNotificationsWithIdentifier:widgetIdentifier andCallback:^ void () {
      mediaCallback();
    }];
    
    if (timeElapsedChangedCallback) { // Allow being falsey for second operand.
      [IS2Media registerForTimeInformationWithIdentifier:widgetIdentifier andCallback:^ void () {
        timeElapsedChangedCallback();
      }];
    }
  },
  // helper function, don't call manually unless you really know what you're doing.
  onunload: function() {
    [IS2Media unregisterForNotificationsWithIdentifier:widgetIdentifier];
    [IS2Media unregisterForTimeInformationWithIdentifier:widgetIdentifier];
  },
  
  // Controls
  play: function() {
    [IS2Media play];
  },
  pause: function() {
    [IS2Media pause];
  },
  previousTrack: function() {
    [IS2Media skipToPreviousTrack];
  },
  nextTrack: function() {
    [IS2Media skipToNextTrack];
  },
  setVolume: function(percentage, showHUD) {
    [IS2Media setVolume:percentage withVolumeHUD:showHUD];
  },
  
  // Data access
  getTrackTitle: function() {
    return [IS2Media currentTrackTitle];
  },
  getTrackArtist: function() {
    return [IS2Media currentTrackArtist];
  },
  getTrackAlbum: function() {
    return [IS2Media currentTrackAlbum];
  },
  getTrackArtworkBase64String: function() {
    return [IS2Media currentTrackArtworkBase64];
  },
  getTrackLength: function() {
    return [IS2Media currentTrackLength];
  },
  getTrackElapsedTime: function() {
    return [IS2Media elapsedTrackLength];
  },
  getTrackNumber: function() {
    return [IS2Media trackNumber];
  },
  getTrackCountInAlbum: function() {
    return [IS2Media totalTrackCount];
  },
  
  // State of controls
  getNowPlayingAppIdentifier: function() {
    return [IS2Media currentPlayingAppIdentifier];
  },
  getIsPlaying: function() {
    return [IS2Media isPlaying];
  },
  getIsShuffleEnabled: function() {
    return [IS2Media shuffleEnabled];
  },
  getIsPlayingFromItunesRadio: function() {
    return [IS2Media iTunesRadioPlaying];
  },
  getIsTrackAvailable: function() {
    return [IS2Media hasMedia];
  },
  getVolumeLevel: function() {
    return [IS2Media getVolume];
  }
};