InfoStats2
==========

InfoStats2 is a far better, and more lightweight implementation of my original InfoStats2. It allows both HTML/JS and Objective-C developers to access system information, and to call system functions without the need for reverse engineering. 

HTML

For the HTML side of things, Cycript is injected into all instances of UIWebView within SpringBoard (hence the dependancy on saurik's WebCycript). As a result, any function provided by InfoStats2 is accessed via Cycript, which is completely native alongside JavaScipt code.
To make things even easier, in the Releases section of this repository can be found multiple libraries that further simplify retrieving information from this tweak.

Objective-C

For those using this within tweaks, retrieving data is as simple as calling class methods; there is no need to allocate an instance of anything. Additionally, there is no need to link against InfoStats2 to obtain data from it, simply get its class via the Objective-C runtime - objc_getClass("IS2Extensions") - and call whatever method you need. Simple.

iOS version compatiblity

One major advantage of using InfoStats2 in your projects is the fact that it supports all version of iOS from 5.1. As a result, you do not need to worry about updating your own code in relation to changes internally in iOS; this library handles it for you.

API

Both HTML/JS and Objective-C share the same API, which is available //here//. There is a section within that link for HTML/JS developers which shows how to call functions within Cycript; for Objective-C, it is assumed that you know how to do this.

Building

You need to modify Targets > Build Phases > Link with libraries and ensure that you are linking to your copy of libWebCycript and libsubstrate - you can retrieve these from your device. Build the IS2WeatherDaemon target first, and then the InfoStats2 target to build the resulting debian package.