#!/bin/bash

set -e

showHelp()
{
  # Show optional  error message
  if ! [[ -v $1 ]]; then showInfo "$1"; fi

  # Display Help
  echo
  echo "======================================================="
  echo
  echo -e "\e[1mConvert Videos\e[0m"
  echo
  echo "Syntax: \e[1m bash videoConvert.sh [-i|o|c|r|p|help] \e[0m"
  echo
  echo "Options:"
  echo -e "\e[1m -i \e[0m     Video input type e.g mp4"
  echo -e "\e[1m -o \e[0m     Video output type e.g mp4"
  echo -e "\e[1m -c \e[0m     Conversion codec i.e. av1, hevc or h264"
  echo -e '\e[1m -r \e[0m     Delete original  file after finishing  i.e. either "y" or "n" '
  echo -e '\e[1m -p \e[0m     Path to where files reside in using the full path name e.g. /home/Videos - default is script location i.e. \e[1m $(pwd) \e[0m'
  echo -e "\e[1m -help \e[0m  Print this \e[1mhelp screen \e[0m"
  echo
  echo  "======================================================"
  echo
}

showInfo() {
  echo
  echo "======================================================="
  echo -e ${1}
  echo "======================================================="
  echo
}

cleanUp() {
  showInfo "Script externaly stopped! Exiting download process gracefully..."
  exit 1
}

trap cleanUp INT SIGINT SIGTERM

# Default parameters
codecs=("av1", "hevc", "h264")
chargingStates=('fully-charged', 'charging')
inputfiletype="mp4"
outputfiletype="mp4"
codec="hevc"
removeFile="n"
path="$(pwd)/"

while getopts i:o:c:r:p:h: option
do
	case "${option}" in
        i) inputfiletype=${OPTARG};;
        o) outputfiletype=${OPTARG};;
        c)
          if [ ${OPTARG} != "" ]; then codec=${OPTARG}; fi ;;
        r) 
          if [ ${OPTARG} = "y" ] || [ ${OPTARG} = "n" ] ; then removeFile=${OPTARG}; else showInfo "Error: The \e[1mremove folder\e[0m value should either be \e[1myes\e[0m or \e[1mno\e[0m."; exit; fi ;;
        p)
          folder=${OPTARG}
          if ! [[ $folder == */ ]]; then folder="$folder/"; showInfo "String has been changed to $folder"; fi 
          if [ ! -d "$folder" ]; then showInfo "Error: The $folder directory does not exist!"; exit; else path=$folder; fi ;;
        h) 
          if ! [[ ${OPTARG} == "elp" ]] ; then showInfo "Error: The \e[1mhelp\e[0m argument should be \e[1m-help\e[0m."; exit; else showHelp; exit; fi;;
        *) showInfo "Error: Invalid option selected!"; exit;;
    esac
done

if [[ ! ${codecs[@]} =~ $output ]]
then 
  showHelp "Error: The \e[1mCodec\e[0m value is incorrect i.e -c must be either "av1", "hevc" or "h264"! "
  exit 1
fi

echo
echo "#######################################################"
echo "#######################################################"
echo
echo "PARAMETERS USED IN CONVERSION "
echo
echo "Input file format                     =>  $inputfiletype"
echo "Output file format                    =>  $outputfiletype"
echo "Video codec                           =>  $codec"
echo "Remove original video?                =>  $removeFile"
echo "Video directory                       =>  $path"
echo
echo "#######################################################"
echo "#######################################################"
echo

totalfiles=$(find "$path" -maxdepth 1 -name "*.$inputfiletype" | wc -l)
showInfo "There is $totalfiles video files in this folder."
declare -i count=0

if [[ $totalfiles -gt 0 ]]
then
  
  if [ ! -d "$path/CON" ]; then mkdir -p "$path/CON"; fi
  if [ ! -d "$path/DONE" ]; then mkdir -p "$path/DONE"; fi

  for file in *.$inputfiletype
  do
    
    
    chargingState=$(upower -i $(upower -e | grep '/battery') | grep --color=never -E state|xargs|cut -d' ' -f2)
    batteryPower=$(upower -i $(upower -e | grep '/battery') | grep --color=never -E percentage|xargs|cut -d' ' -f2|sed s/%//)

    if [[ ${chargingStates[@]} =~ $chargingState ]] || [[ $batteryPower -gt 50 ]]
    then

      count+=1
      showInfo "Started converting video file No. $count of $totalfiles titled '$file'..."

      urlremoved="${file##*/}"
      filetyperemoved="${urlremoved%.*}"
      
      if [[ $codec == "av1" ]]
      then
        showInfo "Converting using av1..."
        time ffmpeg -i "$file" -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v libsvtav1 -preset 5 -crf 32 -g 240 -pix_fmt yuv420p10le -svtav1-params tune=0:film-grain=8 -c:a copy "${path}CON/${filetyperemoved}.${outputfiletype}"
      elif [[ $codec == "hevc" ]]
      then 
        showInfo "Converting using hevc..."
        time ffmpeg -i "$file" -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v libx265 -pix_fmt yuv420p -profile:v main -preset slower -crf 27 -c:a copy "${path}CON/${filetyperemoved}.${outputfiletype}"
      else
        showInfo "Converting using h264..."
        time ffmpeg -i "$file" -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v libx264 -pix_fmt yuv420p -profile:v high -level 4.1 -preset slower -crf 22 -tune film -c:a copy "${path}CON/${filetyperemoved}.${outputfiletype}"
      fi

      if [ ! -f "${path}CON/${filetyperemoved}.${outputfiletype}" ]
      then
        showInfo "${filetyperemoved}.${outputfiletype} was not found after conversion!"
      else
        if [ $removeFile == "y" ]  
        then
          rm -R "$file"
          showInfo "The video file No. $count of $totalfiles titled '$file' has been converted to the CON folder, and the original file deleted."
        else
          mv "$file" "${path}DONE/${urlremoved}"
          showInfo "The video file No. $count of $totalfiles titled '$file' has been converted to the CON folder, and the original file moved to the DONE folder."
        fi
      fi

    else 
      showInfo "Error: Battery power is $batteryPower%. EXiting script to save battery energy and protect it from overdraw."
      exit 1
    fi

  done
  
  showInfo "Finished converting $count of $totalfiles video files in this folder."
else
  echo "No files with extension $inputfiletype found so no conversion took place."
fi