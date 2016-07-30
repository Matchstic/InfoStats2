(This readme will be changed soon, at the moment it's used as the index page for documentation: http://incendo.ws/projects/InfoStats2/)

InfoStats 2 is a far better implementation of the original InfoStats. It allows both HTML/JS and Objective-C developers to access various information, and to call system functions without the need for reverse engineering. In short, it's a powerful, easy-to-use API.

At the bottom of this page can be found references to all the classes that make up this API, along with their constituent methods.

HTML
----

For the HTML side of things, Cycript is injected into all instances of UIWebView within SpringBoard (hence the dependency on Saurik's WebCycript). As a result, any function provided by InfoStats2 is accessed via Cycript, which is completely native alongside JavaScript code.

To make things even easier, <b>examples</b> for using each of the many parts of the provided API can be found here: <a href="downloads/ExampleWidgets.zip">examples.zip</a>.

Also, a quick, no-nonsense guide to Cycript and this API (<b>recommended reading</b>) can be found <a href="api_intro_html.html">here</a>.

Objective-C
-----------

For those using this within tweaks, retrieving data is as simple as calling class methods; there is no need to allocate an instance of anything. Additionally, there is no need to link against InfoStats 2 to obtain data from it, simply get its class via the Objective-C runtime - eg, <code>objc_getClass(<span style="color:#800000">"IS2System"</span>)</code> - and call whatever method you need.

<b>Headers</b> can be found here: <a href="downloads/Headers.zip">headers.zip</a>.

iOS Version Compatibility
------------------------

A major advantage of using InfoStats 2 in your projects is the fact that it supports all version of iOS from 6.0. As a result, you do not need to worry about updating your own code in relation to changes internally in iOS; this library handles it for you.
