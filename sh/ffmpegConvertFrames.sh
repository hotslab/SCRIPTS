#!/bin/bash

showHelp()
{
   # Display Help
   echo -e "\e[1mConvert video files to smaller size \e[0m"
   echo
   echo "Syntax: bash convert.sh [-d|i|f|l|help]"
   echo "Options:"
   echo -e "-d      Directory the files are in using the full path name e.g. /home/Videos - default is script location i.e. \e[1m $(pwd) \e[0m"
   echo -e "-i      Input file type e.g .mp4 - default is \e[1m mp4 \e[0m"
   echo -e "-f      Video Frames per second .e.g 60 - default is \e[1m 24 \e[0m"
   echo -e "-l      Framerate to be modified limit range .e.g 24 - default is \e[1m 0 \e[0m"
   echo -e "-help   Print this \e[1m Help Screen \e[0m"
   echo
}

showInfo() {
  echo
  echo "======================================================="
  echo -e "${1}"
  echo "======================================================="
  echo
}

roundNumber() {
  printf "%.${2}f" "${1}"
}

# Default parameters
directory="$(pwd)/"
inputfiletype="mp4"
newFPS=24
fpsLimit=0

while getopts d:i:f:l:h: option
do
	case "${option}" in
        d)
          folder=${OPTARG}
          if ! [[ $folder == */ ]]; then folder="$folder/"; showInfo "String has been changed to $folder"; fi 
          if [ ! -d "$folder" ]; then showInfo "Error: The $folder directory does not exist!"; exit; else directory=$folder; fi ;;
        i) inputfiletype=${OPTARG};;
        f)
          re='^[0-9]+$'
          if ! [[ ${OPTARG} =~ $re ]] ; then showInfo "Error: The \e[1mfps value\e[0m i.e \e[1m-f\e[0m is empty or not a number!"; exit; else newFPS=${OPTARG}; fi ;;
        l)
          re='^[0-9]+$'
          if ! [[ ${OPTARG} =~ $re ]] ; then showInfo "Error: The \e[1mfps limit value\e[0m i.e \e[1m-l\e[0m is empty or not a number!"; exit; else fpsLimit=${OPTARG}; fi ;;
        h)
          if ! [[ ${OPTARG} == "elp" ]] ; then showInfo "Error: The \e[1mhelp\e[0m argument should be \e[1m-help\e[0m."; exit; else showHelp; exit; fi;;
        *) showInfo "Error: Invalid option selected!"; exit;;
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
echo "Framerate = $newFPS"
echo "Framerate to be modified limit range = $fpsLimit"
echo
echo "#######################################################"
echo "#######################################################"
echo

totalfiles=$(find "$directory" -maxdepth 1 -name "*.$inputfiletype" | wc -l)
showInfo "There are $totalfiles video files in this folder."
declare -i count=0

if [[ $totalfiles -gt 0 ]]; then
  if [ ! -d "$directory/FPSCON" ]; then mkdir -p "$directory/FPSCON"; fi
  if [ ! -d "$directory/FPSDONE" ]; then mkdir -p "$directory/FPSDONE"; fi
 
  while IFS= read -r -d '' i; 
  do
    count+=1

    showInfo "Started converting video file No. $count of $totalfiles titled '$i'..."

    fpsData=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=s=x:p=0 "$i")
    OLDIFS=$IFS
    IFS='/' read -ra originalFPSArray <<< "$fpsData"

    showInfo "Video's original fps data is ${originalFPSArray[0]}/${originalFPSArray[1]}"
    
    originalFPS=$(bc -l <<< "(${originalFPSArray[0]} / ${originalFPSArray[1]})")
    originalFPS=$(roundNumber "${originalFPS}" 0)

    showInfo "Calculated video framerate is $originalFPS"

    IFS=$OLDIFS
    urlremoved="${i##*/}"
    filetyperemoved="${urlremoved%.*}"

    if [ "$originalFPS" -ge "$fpsLimit" ] ; then
      if  [ "$originalFPS" -ne "$newFPS" ] ; then
        showInfo "Converting video with new fps of $newFPS..."
        ffmpeg -y -i "$i" -filter:v fps=fps="${newFPS}" -c:v libx265 -c:a aac -ab 128k -ar 44100 "${directory}FPSCON/${filetyperemoved}.${inputfiletype}" < /dev/null
        mv "$i" "${directory}FPSDONE/${urlremoved}"
        showInfo "The video file No. $count of $totalfiles titled '$i' has been converted to the FPSCON folder, and the original file moved to the FPSDONE folder."
      else
        showInfo "The video file No. $count of $totalfiles titled '$i' already has the specified fps $newFPS. No further action done on the file."
      fi
    else
      showInfo "The video file No. $count of $totalfiles titled '$i' fps is less or equal to the limited fps of $fpsLimit. No further action done on the file."
    fi
  done < <(find "$directory" -maxdepth 1 -name "*.$inputfiletype" -print0)
  unset IFS
  showInfo "Finished converting $count of $totalfiles video files in this folder."
else
  showInfo "No files with extension $inputfiletype found so no conversion took place."
fi
