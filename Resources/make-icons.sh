#!/bin/bash

source ./svg2png.sh

svg2png "$(pwd)" "AppIcon.svg" "$(pwd)/Assets.xcassets/AppIcon.appiconset" "20:1,2,3 29:1,2,3 40:1,2,3 60:2,3 76:1,2 83.5:2 1024:1" false
svg2png "$(pwd)" "Launchscreen.svg" "$(pwd)/Assets.xcassets/Launchscreen.imageset" "1000:1,2,3" false
svg2png "$(pwd)" "Background.svg" "$(pwd)/Assets.xcassets/Background.imageset" "1000:1,2,3" false
