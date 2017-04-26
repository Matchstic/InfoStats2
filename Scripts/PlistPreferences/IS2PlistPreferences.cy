// Used to be able to access settings from the provided settings plist.
var IS2PlistPreferences = {
  init: function() {
    
  },
  getValue: function(key, defaultValue) {
    if (!is2Available) {
      return defaultValue;
    } else {
      // Get value from dict.
  },
  setValue: function(key, newValue) {
  
  }
};