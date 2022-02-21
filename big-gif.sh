#!/usr/bin/env sh

VIDEO=$1
WIDTH_COUNT=$2
HEIGHT_COUNT=$3
PREFIX=$4
START=00:00:05.6
STOP=00:00:06.95

# Compute the width and height of the video
WIDTH=$(mediainfo $VIDEO --Output=JSON | jq '.media.track | .[] | select(."@type" == "Video") | .Width' | sed 's/"//g')
HEIGHT=$(mediainfo $VIDEO --Output=JSON | jq '.media.track | .[] | select(."@type" == "Video") | .Height' | sed 's/"//g')

echo $VIDEO is $WIDTH x $HEIGHT

# Trim the video and crop it to make it square
ffmpeg -i $VIDEO -ss $START -to $STOP -filter:v "crop=$HEIGHT:$HEIGHT:0:0" -an -y output/trim.mp4

echo Cropped video is $HEIGHT x $HEIGHT

INC=$(echo $HEIGHT $HEIGHT_COUNT /p | dc)

for i in $(seq 0 $(echo $HEIGHT_COUNT 1-p | dc)); do
  x=$(echo $i $INC*p | dc)
  for j in $(seq 0 $(echo $HEIGHT_COUNT 1-p | dc)); do
    y=$(echo $j $INC*p | dc)
    echo [$i, $j]: [$x, $y]
    ffmpeg -i output/trim.mp4 -filter:v "crop=$INC:$INC:$x:$y" -y output/$i-$j.mp4
    ffmpeg -i output/$i-$j.mp4 -filter_complex "[0:v] fps=12,scale=w=128:h=-1" -y output/$PREFIX$i-$j.gif
  done
done
