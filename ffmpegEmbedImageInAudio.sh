#!/bin/bash

mkdir -p "CON"

for file in *.$1
    do echo "Processing $file"
    # ffmpeg -i "$file" -acodec libmp3lame "CON/${file%.*}.mp3"
    ffmpeg -i "$file" -i "$2" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "CON/${file%.*}.mp3"
done