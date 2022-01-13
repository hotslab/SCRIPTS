#!/bin/bash

Help()
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

round() {
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
          if ! [[ $folder == */ ]]; then folder="$folder/"; echo; echo "String has been changed to $folder"; echo; fi 
          if [ ! -d "$folder" ]; then echo; echo "Error: The $folder directory does not exist!"; echo; exit; else directory=$folder; fi ;;
        i) inputfiletype=${OPTARG};;
        f)
          re='^[0-9]+$'
          if ! [[ ${OPTARG} =~ $re ]] ; then echo; echo -e "Error: The \e[1mfps value\e[0m i.e \e[1m-f\e[0m is empty or not a number!"; echo; exit; else newFPS=${OPTARG}; fi ;;
        l)
          re='^[0-9]+$'
          if ! [[ ${OPTARG} =~ $re ]] ; then echo; echo -e "Error: The \e[1mfps limit value\e[0m i.e \e[1m-l\e[0m is empty or not a number!"; echo; exit; else fpsLimit=${OPTARG}; fi ;;
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
echo "Framerate = $newFPS"
ECHO "Framerate to be modified limit range = $fpsLimit"
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
  
  
  if [ ! -d "$directory/FPSCON" ]; then mkdir -p "$directory/FPSCON"; fi
  if [ ! -d "$directory/FPSDONE" ]; then mkdir -p "$directory/FPSDONE"; fi
 
  while IFS= read -r -d '' i; 
  do
    count+=1
    echo
    echo "======================================================="
    echo "Started converting video file No. $count of $totalfiles titled '$i'..."
    echo "======================================================="
    echo

    fpsData=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=s=x:p=0 "$i")

    OLDIFS=$IFS

    IFS='/' read -ra originalFPSArray <<< "$fpsData"

    echo
    echo "======================================================="
    echo "Video's original fps data is ${originalFPSArray[0]}/${originalFPSArray[1]}"
    echo "======================================================="
    echo
    
    originalFPS=$(bc -l <<< "(${originalFPSArray[0]} / ${originalFPSArray[1]})")
    originalFPS=$(round ${originalFPS} 0)
    
    echo
    echo "======================================================="
    echo "Calculated video framerate is $originalFPS"
    echo "======================================================="
    echo

    IFS=$OLDIFS

    urlremoved="${i##*/}"
    filetyperemoved="${urlremoved%.*}"

    if [ $originalFPS -ge $fpsLimit ] ; then
      if  [ $originalFPS -ne $newFPS ] ; then
        echo
        echo "======================================================="
        echo "Converting video with new fps of $newFPS..."
        echo "======================================================="
        echo
        ffmpeg -y -i "$i" -filter:v fps=fps="${newFPS}" "${directory}FPSCON/${filetyperemoved}.${inputfiletype}" < /dev/null
      else
        echo
        echo "======================================================="
        echo "The video file No. $count of $totalfiles titled '$i' already has the specified fps $newFPS. No further action done on the file."
        echo "======================================================="
        echo
      fi
    else
      echo
      echo "======================================================="
      echo "The video file No. $count of $totalfiles titled '$i' fps is less or equal to the limited fps of $fpsLimit. No further action done on the file."
      echo "======================================================="
      echo
    fi

    mv "$i" "${directory}FPSDONE/${urlremoved}"

    echo
    echo "======================================================="
    echo "The video file No. $count of $totalfiles titled '$i' has been converted to the FPSCON folder, and the original file moved to the FPSDONE folder."
    echo "======================================================="
    echo
  done < <(find "$directory" -maxdepth 1 -name "*.$inputfiletype" -print0)

  unset IFS

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
