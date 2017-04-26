Each of these scripts are written to be used simply by dropping them into your widget’s directory, and linking them into your main .html file in the <head> tag like so:

<head>
…

<script type="text/javascript" src="js/IS2Config.js"></script>
<script type="text/cycript" src="js/<script>.cy"></script> 
^^^ (repeat this line for each script you want to use)

…
</head>


For each script, there’s instructions included on how to set them up at the top of the respective scripts.

*** You *must* include IS2Config.js, and configure it as required to suit your widget. This contains various values used throughout the scripts to make your life easier. They won’t quite cure hair loss, but will speed up coding widgets. ***

==================================================================================

Examples of all this in use can be found in the Examples folder.

==================================================================================

Each of these scripts are coded to allow your widget to function when IS2 isn’t available, such as when testing it in a web browser.

Make sure to sign up to the mailing list for whenever I push new updates of these scripts, found at: <insert_url_here>