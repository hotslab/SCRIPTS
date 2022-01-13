#!/bin/bash

Help()
{
   # Display Help
   echo -e "\e[1mConvert video files to smaller size \e[0m"
   echo
   echo "Syntax: bash convert.sh [-d|i|o|v|a|s|r|help]"
   echo "Options:"
   echo -e "-d     Directory the files are in using the full path name e.g. /home/Videos - default is script location i.e. \e[1m $(pwd) \e[0m"
   echo -e "-i     Input file type e.g .mp4 - default is \e[1m mp4 \e[0m"
   echo -e "-o     Output file type e.g .mp4 - default is \e[1m mp4 \e[0m"
   echo -e "-v     Video codec .e.g libx265 - default is \e[1m libx256 \e[0m"
   echo -e "-a     Audio codec .e.g aac - default is \e[1m aac -ab 128k -ar 44100 \e[0m"
   echo -e "-s     Maximum scale dimension for video .e.g 1080 or 720 - default is \e[1m 1080 \e[0m"
   echo -e "-r     Remove folders when done i.e. \e[1m yes \e[0m or \e[1m no \e[0m - default is \e[1m no \e[0m"
   echo -e "-help  Print this \e[1m Help Screen \e[0m"
   echo
}

# Default parameters
directory="$(pwd)/"
inputfiletype="mp4"
outputfiletype="mp4"
videocodec="libx265 -crf 30"
audiocodec="aac -ab 128k -ar 44100"
scale=1080
removefolders="no"

while getopts d:i:o:v:a:s:r:h: option
do
	case "${option}" in
        d)
          folder=${OPTARG}
          if ! [[ $folder == */ ]]; then folder="$folder/"; echo; echo "String has been changed to $folder"; echo; fi 
          if [ ! -d "$folder" ]; then echo; echo "Error: The $folder directory does not exist!"; echo; exit; else directory=$folder; fi ;;
        i) inputfiletype=${OPTARG};;
        o) outputfiletype=${OPTARG};;
        v) videocodec=${OPTARG};;
        a) audiocodec=${OPTARG};;
        s)
          re='^[0-9]+$'
          if ! [[ ${OPTARG} =~ $re ]] ; then echo; echo "Error: The \e[1mscale\e[0m value i.e -s is empty or not a number!"; echo; exit; else scale=${OPTARG}; fi ;;
        r) 
          if [ ${OPTARG} == "yes" ] || [ ${OPTARG} == "no" ] ; then removefolders=${OPTARG}; else echo; echo -e "Error: The \e[1mremove folder\e[0m value should either be \e[1myes\e[0m or \e[1mno\e[0m."; echo; exit; fi ;;
        h) 
          if ! [[ ${OPTARG} == "elp" ]] ; then echo; echo -e "Error: The \e[1mhelp\e[0m argument should be \e[1m-help\e[0m."; echo; exit; else Help; exit; fi;;
        *) echo "Error: Invalid option selected!"; exit;;
    esac
done

echo
echo "#######################################################"
echo "#######################################################"
echo
echo "PARAMETERS USED IN CONVERSION "
echo
echo "Video directory = $directory"
echo "Input file format = $inputfiletype"
echo "Output file format = $outputfiletype"
echo "Video codec = $videocodec"
echo "Audio codec = $audiocodec"
echo "Video dimension scale = $scale"
echo "Remove conversion folders? = $removefolders"
echo
echo "#######################################################"
echo "#######################################################"
echo

totalfiles=$(find "$directory" -maxdepth 1 -name "*.$inputfiletype" | wc -l)

echo
echo "======================================================="
echo "There are $totalfiles video files in this folder."
echo "======================================================="
echo

declare -i count=0

if [[ $totalfiles -gt 0 ]]; then
  
  
  if [ ! -d "$directory/CON" ]; then mkdir -p "$directory/CON"; fi
  if [ ! -d "$directory/DONE" ]; then mkdir -p "$directory/DONE"; fi
 
  while IFS= read -r -d '' i; 
  do
    count+=1
    echo
    echo "======================================================="
    echo "Started converting video file No. $count of $totalfiles titled '$i'..."
    echo "======================================================="
    echo

    height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 "$i")
    width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$i")

    echo
    echo "======================================================="
    echo "Height and width of '$i' is: height = $height and width = $width "
    echo "======================================================="
    echo

    urlremoved="${i##*/}"
    filetyperemoved="${urlremoved%.*}"

    if [[ "${urlremoved}" != *-converted.${inputfiletype} ]]; then
      if  [ $height -gt $scale ] || [ $width -gt $scale ]; then
        if [ $width -gt $height ]; then
          echo
          echo "======================================================="
          echo "Changing dimensions by width..."
          echo "======================================================="
          echo
          truncated=$(bc -l <<< "($height / $width) * $scale")
          truncated=$(( ((${truncated%.*}+5)/10)*10 ))
          echo
          echo "Width truncated to $truncated"
          echo
          ffmpeg -y -i "$i" -vf scale="${scale}:${truncated}" -c:v $videocodec -c:a $audiocodec "${directory}CON/${filetyperemoved}-converted.${outputfiletype}" < /dev/null
        else
          echo
          echo "======================================================="
          echo "Changing dimensions by height..."
          echo "======================================================="
          echo
          truncated=$(bc -l <<< "($width / $height) * $scale")
          truncated=$(( ((${truncated%.*}+5)/10)*10 ))
          echo
          echo "Height truncated to $truncated"
          echo
          ffmpeg -y -i "$i" -vf scale="${truncated}:${scale}" -c:v $videocodec -c:a $audiocodec "${directory}CON/${filetyperemoved}-converted.${outputfiletype}" < /dev/null
        fi
      else
        echo
        echo "======================================================="
        echo "No dimensions have been changed."
        echo "======================================================="
        echo
        ffmpeg -y -i "$i" -c:v $videocodec -c:a $audiocodec "${directory}CON/${filetyperemoved}-converted.${outputfiletype}" < /dev/null
      fi

      mv "$i" "${directory}DONE/${urlremoved}"

      echo
      echo "======================================================="
      echo "The video file No. $count of $totalfiles titled '$i' has been converted to the CON folder, and the original file moved to the DONE folder."
      echo "======================================================="
      echo
    else
      echo
      echo "======================================================="
      echo "The video file No. $count of $totalfiles titled '$i' was already converted. No further action done on the file."
      echo "======================================================="
      echo
    fi
  done < <(find "$directory" -maxdepth 1 -name "*.$inputfiletype" -print0)

  unset IFS
    

  if [ $removefolders == "yes" ] && [ $totalfiles -eq $count ]; then
    if [ -d "$directory/CON" ]; then mv ${directory}CON/* "$directory"; rm -R "${directory}CON"; fi
    if [ -d "$directory/DONE" ]; then rm -R "${directory}DONE"; fi
  fi

  echo
  echo "======================================================="
  echo "Finished converting $count of $totalfiles video files in this folder."
  echo "======================================================="
  echo

else

  echo
  echo "======================================================="
  echo "No files with extension $inputfiletype found so no conversion took place."
  echo "======================================================="
  echo

fi
