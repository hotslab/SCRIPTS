#!/bin/bash

if [[ $1 == "" ]]; then echo "No last number of numbered directories was passed e.g. 9 or 18"; exit; fi
if [[ $2 == "" ]]; then echo "No audio file type was passed e.g. vocals for vocals.wav"; exit; fi
if [[ $3 == "" ]]; then echo "No output file type was specified e.g. wav or opus"; exit; fi
if [[ $4 == "" ]]; then echo "No output directory was specified e.g. "My New Song" "; exit; fi

showInfo() {
  echo
  echo "======================================================="
  echo -e ${1}
  echo "======================================================="
  echo
}

removeFiles() {
  rm -R COMBINE list.txt
}

mkdir -p "COMBINE"
touch list.txt

count=1
folderCount=$1 
fileType=$2
outputFile=$3
outputDir=$4

mkdir -p "$outputDir"

while [ $count -le $(( $folderCount + 1 )) ]
do
	if ! [[ -f "$count/$fileType.wav" ]]; then showInfo "File $count/$fileType.wav not found";  break; fi
	showInfo "Processing $count/$fileType.wav"
	cp  "$count/$fileType.wav" "COMBINE/$count.wav"
	echo "file 'COMBINE/$count.wav'" >> list.txt
	count=$(($count + 1))
done

ffmpeg -f concat -safe 0 -i list.txt -c copy "$outputDir/$fileType.wav"

if ! [[ -f "$outputDir/$fileType.wav" ]]; then showInfo "File $outputDir/$fileType.wav failed being created!"; removeFiles; exit; else showInfo "File $outputDir/$fileType.wav was created succesfully"; fi

if ! [[ $outputFile == "wav" ]]; then showInfo "Converting to $outputDir/$fileType.$outputFile..."; ffmpeg -i "$outputDir/$fileType.wav" "$outputDir/$fileType.$outputFile"; rm "$outputDir/$fileType.wav"; fi

removeFiles
