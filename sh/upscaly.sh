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
model="${3:-RealESRGAN_General_WDN_x4_v3}"


if ! [[ $path == */ ]]; then path="$path/"; showInfo "String has been changed to $path"; fi 

if [ ! -d "$path" ]; then showInfo "Error: The $path directory does not exist!"; exit 1; fi

if [ ! -d "${path}UPSCALED" ]; then mkdir -p "${path}UPSCALED"; fi

totalfiles=$(find "$path" -maxdepth 1 -name "*.$inputFiletype" | wc -l)
showInfo "There is \e[1m$totalfiles\e[0m video files in \e[1m$path\e[0m with extension \e[1m$inputFiletype\e[0m."
declare -i count=0

for file in "$path"*."$inputFiletype"
do
    count+=1

    showInfo "Started converting video file No. $count of $totalfiles titled \e[1m$file\e[0m."

    urlremoved="${file##*/}"
    filetyperemoved="${urlremoved%.*}"

    if [ ! -f "${path}UPSCALED/${filetyperemoved}.png" ]
    then
      time /home/joseph/PROJECTS/upscayl-bin/upscayl-bin -v -g 0 -i "$file" -n "${model}" -m models/ -c 100 -o "${path}UPSCALED/${filetyperemoved}.png"
    else
      showInfo "${path}UPSCALED/${filetyperemoved}.png already exists. Skipping conversion."
    fi

    # rm -R "$file"

done

showInfo "Finished converting \e[1m$count\e[0m of \e[1m$totalfiles\e[0m files in this folder."