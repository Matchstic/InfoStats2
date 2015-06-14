#!/bin/bash

if type "/opt/iOSOpenDev/bin/ldid" > /dev/null; 
then
    /opt/iOSOpenDev/bin/ldid -Sentitlements.plist LatestBuild/infostats2d
elif type "/usr/bin/ldid" > /dev/null;
then
    /usr/bin/ldid -Sentitlements.plist LatestBuild/infostats2d
elif type "/usr/local/bin/ldid" > /dev/null;
then
    /usr/local/bin/ldid -Sentitlements.plist LatestBuild/infostats2d
elif type "ldid" > /dev/null;
then
    ldid -Sentitlements.plist LatestBuild/infostats2d
else
    echo "Could not find ldid on your system (searched /usr/bin, /usr/local/bin, /opt/iOSOpenDev/bin/)"
    exit 1
fi

echo "Set entitlements..."
cp LatestBuild/infostats2d InfoStats2/Package/usr/bin/infostats2d
echo "Moved daemon into Package dir"
echo "Build InfoStats2 target now to create deb"