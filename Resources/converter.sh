#!/bin/bash

addSvg2pngCommand () {
  echo "###########################################################################"
  echo "SVG to PNG for squared SVG wiht 100x100 pixel size! no other svg size work"
  echo "###########################################################################"
  echo "input svg filepath is $1"
  INPUT_FILEPATH=$1
  echo "input svg filename is $2"
  INPUT_FILENAME=$2
  echo "output filepath is $3"
  OUTPUT_FILEPATH=$3
  echo "resolutions are $4"
  RESOLUTIONS=$4
  echo "overriding files? is $5"
  OVERRIDE=$5
  echo "###########################################################################"
  echo "###########################################################################"
    
  for RESOLUTION in $RESOLUTIONS
  do
    echo "Converting to $RESOLUTION pixel resolution"
    FILENAME=${INPUT_FILENAME%.svg}
    
    SCALES=$(echo $RESOLUTION | cut -f2 -d:)
    RESOLUTION=$(echo $RESOLUTION | cut -f1 -d:)
    
    SCALES=$(echo "$SCALES" | tr ',' ' ')
    
    for SCALE in $SCALES
    do
      if [[ "${SCALE}" == "1" ]]; then
        DESTINATION=$OUTPUT_FILEPATH/$FILENAME$RESOLUTION.png
      else
        DESTINATION=$OUTPUT_FILEPATH/$FILENAME$RESOLUTION"@"$SCALE"x.png"
      fi
      NEW_RES=$(echo "$RESOLUTION * $SCALE" | bc)

      if [[ "${OVERRIDE}" == "true" ]]; then
        echo -f $INPUT_FILEPATH/$INPUT_FILENAME -e $DESTINATION -y 0 -w $NEW_RES >> commands.txt
      else
        if [ ! -f $DESTINATION ]; then
          echo -f $INPUT_FILEPATH/$INPUT_FILENAME -e $DESTINATION -y 0 -w $NEW_RES >> commands.txt
        else
          echo "Not overriding existing file $DESTINATION"
        fi
      fi
    done
  done
}
