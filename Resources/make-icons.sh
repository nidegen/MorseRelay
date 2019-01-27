#!/bin/bash

fileDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $fileDir

source $fileDir/svg2png.sh

svg2png "$fileDir" "AppIcon.svg" "$fileDir/Assets.xcassets/AppIcon.appiconset" "20:1,2,3 29:1,2,3 40:1,2,3 60:2,3 76:1,2 83.5:2 1024:1" true
svg2png "$fileDir" "DecoderItem.svg" "$fileDir/Assets.xcassets/DecoderItem.imageset" "30:1,2,3" true
svg2png "$fileDir" "EncoderItem.svg" "$fileDir/Assets.xcassets/EncoderItem.imageset" "30:1,2,3" true
svg2png "$fileDir" "Launchscreen.svg" "$fileDir/Assets.xcassets/Launchscreen.imageset" "1000:1,2,3" true
svg2png "$fileDir" "Background.svg" "$fileDir/Assets.xcassets/Background.imageset" "2000:1,2,3" true
svg2png "$fileDir" "HUDImage.svg" "$fileDir/Assets.xcassets/HUDImage.imageset" "50:1,2,3" true
