#!/bin/bash

fileDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $fileDir

source ../Resources/svg2png.sh

svg2png "$fileDir" "AppIcon.svg" "$fileDir/Assets.xcassets/AppIcon.appiconset" "16:1,2 32:1,2 64:1,2 128:1,2 256:1,2 512:1,2" true
