#!/bin/bash

showInfo() {
  echo
  echo "======================================================="
  echo -e ${1}
  echo "======================================================="
  echo
}

if [[ $1 == "" ]]; then echo "No video extension without a preceding dot was passed e.g. mp4"; exit; fi

directory="$(pwd)/"
ext=$1

if [ ! -d "$directory/NEW" ]; then mkdir -p "$directory/NEW"; fi
if [ ! -d "$directory/DONE" ]; then mkdir -p "$directory/DONE"; fi

showInfo "Using extension => $ext"

index=0
for file in *${ext}
do
	index=$((index+1)) 
	audioExt=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=s=x:p=0 "$file")
	showInfo "$index. Processing $file with audio extension $audioExt"
	ffmpeg -i "$file" -vn -acodec copy "${file%.*}.$audioExt"
	if [[ $audioExt != "mp3" ]]
	then
		showInfo "Converting ${file%.*}.$audioExt => ${file%.*}.mp3"
		ffmpeg -i "${file%.*}.$audioExt" "${file%.*}.mp3"
		rm "${file%.*}.$audioExt"							
	fi
	ffmpeg -y -ss 00:05:00.000 -i "$file" -vframes 1 "${file%.*}.jpg"
	ffmpeg -i "${file%.*}.mp3" -i "${file%.*}.jpg" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Audio cover" -metadata:s:v comment="Cover (front)" "${directory}/NEW/${file%.*}.mp3"
	mv "$file" "${directory}/DONE/$file"
	rm  "${file%.*}.mp3" "${file%.*}.jpg"
done

showInfo "Finished processing $index files"
