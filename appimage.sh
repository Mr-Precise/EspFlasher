#!/bin/bash

APP="build/EspFlasher"

DESKTOP="linux/espflasher.desktop"
ICON="linux/icons/hicolor/96x96/apps/espflasher.png"

# clean log space
echo "==================================================================="
echo "                Starting to build the AppImage..."
echo "==================================================================="
echo ""

export VERSION=$(<version.txt)

# version notice
echo "You are building EspFlasher version: $VERSION"
echo ""

# basic tests
if [ ! -f "$APP" ] ; then
    echo "Error: the app file is no in the path we need it, update the APP var on this script"
    exit 1
fi

if [ ! -f "$DESKTOP" ] ; then
    echo "Error: can't find the desktop file, please update the DESKTOP var on the scriot"
    exit 1
fi

if [ ! -f "$ICON" ] ; then
    echo "Error: can't find the default icon, please update the ICON var in the script"
    exit 1
fi

# prepare the ground
rm -rdf AppDir 2>/dev/null
rm -rdf EspFlasher-*.AppImage 2>/dev/null

# download & set all needed tools
wget -c -nv "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
wget -c -nv "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
wget -c -nv "https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-x86_64.AppImage"
chmod a+x *.AppImage

# make sure Qt plugin finds QML sources so it can deploy the imported files
export QML_SOURCES_PATHS=src

./linuxdeploy-x86_64.AppImage -e "$APP" -d "$DESKTOP" -i "$ICON" -p qt --output appimage --appdir=./AppDir
RESULT=$?

# check build success
if [ $RESULT -ne 0 ] ; then
    # warning something gone wrong
    echo ""
    echo "ERROR: Aborting as something gone wrong, please check the logs"
    exit 1
else
    # success
    echo ""
    echo "Success build, check your file:"
    ls -lh EspFlasher-*.AppImage
fi
