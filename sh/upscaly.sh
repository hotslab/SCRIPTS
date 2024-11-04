#!/bin/bash

# fullpath and inputfile

showInfo() {
  echo
  echo "======================================================="
  echo -e ${1}
  echo "======================================================="
  echo
}

path=${1}
inputFiletype=${2}


if ! [[ $path == */ ]]; then path="$path/"; showInfo "String has been changed to $path"; fi 

if [ ! -d "$path" ]; then showInfo "Error: The $path directory does not exist!"; exit 1; else path=$path; fi

if [ ! -d "${$path}UPSCALED" ]; then mkdir -p "${path}UPSCALED"; fi

totalfiles=$(find "$path" -maxdepth 1 -name "*.$inputFiletype" | wc -l)
showInfo "There is \e[1m$totalfiles\e[0m video files in this folder with extension \e[1m$inputFiletype\e[0m."
declare -i count=0

for file in "$path"*.$inputFiletype
do
    count+=1

    showInfo "Started converting video file No. $count of $totalfiles titled \e[1m$file\e[0m."

    urlremoved="${file##*/}"
    filetyperemoved="${urlremoved%.*}"

    if [ ! -f "${path}UPSCALED/${filetyperemoved}.png" ]
    then
      time /opt/Upscayl/resources/bin/upscayl-bin  -i "$file" -o "${path}UPSCALED/${filetyperemoved}.png" -m /opt/Upscayl/resources/models -n realesrgan-x4fast -f png -c 0
    else
      showInfo "${path}UPSCALED/${filetyperemoved}.png already exists. Skipping conversion."
    fi

    rm -R "$file"

done

showInfo "Finished converting \e[1m$count\e[0m of \e[1m$totalfiles\e[0m files in this folder."