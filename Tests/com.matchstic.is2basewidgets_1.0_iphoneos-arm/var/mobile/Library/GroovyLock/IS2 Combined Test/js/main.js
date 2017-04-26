    var weatherTimerLength = 1800000; // 1000 = 1 second, default is half an hour (1800000)
    
    function updateClock() {
          var currentTime = new Date();
          document.getElementById('timeP').innerHTML = "" + timeValueCorrection(currentTime.getHours()) + ":" + timeValueCorrection(currentTime.getMinutes());
          document.getElementById('timeDay').innerHTML = "" + timeToDayNameNotWeather(currentTime);
          document.getElementById('timeRest').innerHTML = "" + timeToMonthName(currentTime) + " " + currentTime.getDate();
    }
    
    function updateWeather() {
        // Begin weather updating
        [IS2Weather updateWeather];
    }
     
     function updateWeatherValues() {
     	document.getElementById('temperature').innerHTML = "" + [IS2Weather currentTemperature];
     	document.getElementById('weatherImg').src = "img/flat_white/" + [IS2Weather currentCondition] + ".png";
	}
	
	function updateNotificationValues() {
       	// We'll be using data from the notification centre, as this will be similar to Window Phone's lockscreen.
       	// Simply pull the data as needed - the method used returns an integer.
       	document.getElementById('phoneNotifCount').innerHTML = "" + [IS2Notifications notificationCountForApplication:"com.apple.mobilephone"];
       	document.getElementById('messagesNotifCount').innerHTML = "" + [IS2Notifications notificationCountForApplication:"com.apple.MobileSMS"];
       	document.getElementById('mailNotifCount').innerHTML = "" + [IS2Notifications notificationCountForApplication:"com.apple.mobilemail"];
	}
	
	function updateCalendarValues() {
     	var timeNow = new Date();
     	var timeInWeek = timeNow.getTime() + (7 * 24 * 60 * 60 * 1000);
     	
     	var eventsArray = JSON.parse("" + [IS2Calendar calendarEntriesJSONBetweenStartTimeAsTimestamp:timeNow.getTime() andEndTimeAsTimestamp:timeInWeek]);
     	
     	if (eventsArray.length > 0) {
           	document.getElementById('noEvents').style.display = "none";
           	document.getElementById('eventsExist').style.display = "inline";
           	
           	// Grab the first event available, as we'll only display one.
           	var event = eventsArray[0];
           	document.getElementById('eventTitle').innerHTML = event.title;
           	document.getElementById('eventLocation').innerHTML = event.location;
           	
           	if (event.allDay == 0) {
                 	// Work out date display.
               	var timeStart = new Date(event.startTimeTimestamp);
               	var timeEnd = new Date(event.endTimeTimestamp);
               	
               	if (timeStart.getDay() == timeEnd.getDay()) {
                   	// Event is all on the same day, huzzah.
                   	var timeString = "" + timeToDayName(timeStart) + ": " + timeValueCorrection(timeStart.getHours()) + ":" + timeValueCorrection(timeStart.getMinutes());
                   	timeString += " to " + timeValueCorrection(timeEnd.getHours()) + ":" + timeValueCorrection(timeEnd.getMinutes());
                   	
                   	document.getElementById('eventTime').innerHTML = timeString;
               	} else {
                     	// Event goes over multiple days...
                     	var timeString = "" + timeToDayName(timeStart) + ", " + timeValueCorrection(timeStart.getHours()) + ":" + timeValueCorrection(timeStart.getMinutes());
                     	timeString += " to " + timeToDayName(timeEnd) + ", " + timeValueCorrection(timeEnd.getHours()) + ":" + timeValueCorrection(timeEnd.getMinutes());
                     	document.getElementById('eventTime').innerHTML = timeString;
               	}
           	} else {
                  document.getElementById('eventTime').innerHTML = "All day";
           	}
     	} else {
           	document.getElementById('noEvents').style.display = "inline";
           	document.getElementById('eventsExist').style.display = "none";
     	}
	}
	
	function timeValueCorrection(value) {
     	if (value < 10) {
           	return "0" + value;
     	} else {
           	return value;
     	}
	}
	
	function timeToDayName(time) {
        var dayNumber = time.getDay();
        var today = new Date();
        var tomorrow = new Date(today.getTime() + (24 * 60 * 60 * 1000));
        
        if (dayNumber == today.getDay()) {
              return "Today";
        } else if (dayNumber == tomorrow.getDay()) {
              return "Tomorrow";
        }
        
        switch(dayNumber) {
            case 0:
              return "Sunday";
            case 1:
              return "Monday";
            case 2:
              return "Tuesday";
            case 3:
              return "Wednesday";
            case 4:
              return "Thursday";
            case 5:
              return "Friday";
            case 6:
              return "Saturday";
            default:
              return "";
          } 
	}
    
    function timeToDayNameNotWeather(time) {
        var dayNumber = time.getDay();

        switch(dayNumber) {
            case 0:
              return "Sunday";
            case 1:
              return "Monday";
            case 2:
              return "Tuesday";
            case 3:
              return "Wednesday";
            case 4:
              return "Thursday";
            case 5:
              return "Friday";
            case 6:
              return "Saturday";
            default:
              return "";
          } 
	}
	
	function timeToMonthName(time) {
     	var monthNumber = time.getMonth();

        switch(monthNumber) {
            case 0:
              return "January";
            case 1:
              return "February";
            case 2:
              return "March";
            case 3:
              return "April";
            case 4:
              return "May";
            case 5:
              return "June";
            case 6:
              return "July";
            case 7:
              return "August";
            case 8:
              return "September";
            case 9:
              return "October";
            case 10:
              return "November";
            case 11:
              return "December";
            default:
              return "";
          } 
	}
    

