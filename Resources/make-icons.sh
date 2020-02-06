#!/bin/bash

fileDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $fileDir

source $fileDir/converter.sh

if [[ "$1" == "o" ]]; then
  overwrite=true
else
  overwrite=false
fi

addSvg2pngCommand $fileDir "AppIcon.svg" "$fileDir/Assets.xcassets/AppIcon.appiconset" "20:1,2,3 29:1,2,3 40:1,2,3 60:2,3 76:1,2 83.5:2 1024:1" $overwrite
addSvg2pngCommand $fileDir "DecoderItem.svg" "$fileDir/Assets.xcassets/DecoderItem.imageset" "30:1,2,3" $overwrite
addSvg2pngCommand $fileDir "EncoderItem.svg" "$fileDir/Assets.xcassets/EncoderItem.imageset" "30:1,2,3" $overwrite
addSvg2pngCommand $fileDir "Launchscreen.svg" "$fileDir/Assets.xcassets/Launchscreen.imageset" "1000:1,2,3" $overwrite
addSvg2pngCommand $fileDir "Background.svg" "$fileDir/Assets.xcassets/Background.imageset" "2000:1,2,3" $overwrite
addSvg2pngCommand $fileDir "HUDImage.svg" "$fileDir/Assets.xcassets/HUDImage.imageset" "50:1,2,3" $overwrite
addSvg2pngCommand $fileDir "EmittIcon.svg" "$fileDir/Assets.xcassets/EmittIcon.imageset" "50:1,2,3" $overwrite
addSvg2pngCommand $fileDir "ReceiveIcon.svg" "$fileDir/Assets.xcassets/ReceiveIcon.imageset" "50:1,2,3" $overwrite

echo "quit" >> commands.txt

inkscape --shell < commands.txt
rm ./commands.txt
