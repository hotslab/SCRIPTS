#!/bin/bash

# exit after error
# set -e

showHelp()
{
  # Show optional  error message
  if [[ ! $1  == "" ]]; then showInfo "$1"; fi

  # Display Help
  echo
  echo "======================================================="
  echo
  echo -e "\e[1mConvert Videos\e[0m"
  echo
  echo -e "Syntax: \e[1mbash videoConvert.sh [-i|o|c|r|p|g|l|q|help]\e[0m"
  echo
  echo -e "\e[1mOptions\e[0m:"
  echo -e "\e[1m -i \e[0m     Video input type e.g default is \e[1mmp4\e[0m"
  echo -e "\e[1m -o \e[0m     Video output type e.g default is \e[1mmp4\e[0m"
  echo -e "\e[1m -c \e[0m     Conversion codec i.e. \e[1mav1, hevc or h264\e[0m"
  echo -e "\e[1m -r \e[0m     Delete original  file after finishing  i.e. either \e[1my\e[0m or \e[1mn\e[0m - default \e[1my\e[0m"
  echo -e "\e[1m -p \e[0m     Path to where files reside in using the full path name e.g. \e[1m/home/Videos\e[0m - default is script location i.e. \e[1m$(pwd)\e[0m"
  echo -e "\e[1m -g \e[0m     Use gpu i.e. either \e[1my\e[0m or \e[1mn\e[0m - default \e[1my\e[0m "
  echo -e "\e[1m -l \e[0m     Gpu path i.e. \e[1m/dev/dri/renderD128\e[0m"
  echo -e "\e[1m -q \e[0m     Video quality scale i.e. \e[1mcrf\e[0m or \e[1mqb\e[0m for \e[1mvaapi\e[0m - defaults to those hardcoded for each encoder in this script"
  echo -e "\e[1m -help \e[0m  Print this \e[1mhelp screen\e[0m"
  echo
  echo  "======================================================"
  echo
}

showInfo() {
  echo
  echo "======================================================="
  echo -e "${1}"
  echo "======================================================="
  echo
}

moveOrDeleteFiles() {
  if [[ $convertedFileAlreadyExists == "n" ]]
  then
    if [ ! -f "${path}CONVERTED/${filetyperemoved}.${outputfiletype}" ]
    then
      showInfo "\e[1m${filetyperemoved}.${outputfiletype}\e[0m was not found after conversion!"
    else
      newFileSize=$( wc -c "${path}CONVERTED/${filetyperemoved}.${outputfiletype}" | awk '{print $1}' )
      showInfo "OLD FILE SIZE >>>> \e[1m${fileSize}\e[0m , NEW FILE SIZE >>>> \e[1m${newFileSize}\e[0m"
      if [ "$removeFile" == "y" ]  
      then
        rm -R "$file"
        mv  "${path}CONVERTED/${filetyperemoved}.${outputfiletype}" "${path}${filetyperemoved}.${outputfiletype}"
        showInfo "The video file No. $count of $totalfiles has been converted to \e[1m${path}${filetyperemoved}.${outputfiletype}\e[0m, and the original file deleted."
      else
        mv "$file" "${path}ORIGINAL/${urlremoved}"
        mv  "${path}CONVERTED/${filetyperemoved}.${outputfiletype}" "${path}${filetyperemoved}.${outputfiletype}"
        showInfo "The video file No. $count of $totalfiles has been converted to \e[1m${path}${filetyperemoved}.${outputfiletype}\e[0m, and the original file moved to \e[1m${path}ORIGINAL/${urlremoved}\e[0m."
      fi
    fi
  fi
}

cleanUp() {
  showInfo "Script externaly stopped! Exiting download process gracefully..."
  exit 1
}

trap cleanUp INT SIGINT SIGTERM

# Default parameters
codecs=("av1" "hevc" "h264")
chargingStates=('fully-charged' 'charging')
inputfiletype="mp4"
outputfiletype="mp4"
codec="hevc"
removeFile="y"
path="$(pwd)/"
gpu="y"
gpuLocation="/dev/dri/renderD128"
videoQuality=""

while getopts i:o:c:r:p:g:l:q:h: option
do
	case "${option}" in
        i) inputfiletype=${OPTARG};;
        o) outputfiletype=${OPTARG};;
        c)
          if [ "${OPTARG}" != "" ]; then codec=${OPTARG}; fi ;;
        r) 
          if [ "${OPTARG}" = "y" ] || [ "${OPTARG}" = "n" ] ; then removeFile=${OPTARG}; else showInfo "Error: The \e[1mremove folder\e[0m value should either be \e[1myes\e[0m or \e[1mno\e[0m."; exit; fi ;;
        p)
          folder=${OPTARG}
          if ! [[ $folder == */ ]]; then folder="$folder/"; showInfo "String has been changed to $folder"; fi 
          if [ ! -d "$folder" ]; then showInfo "Error: The $folder directory does not exist!"; exit; else path=$folder; fi ;;
        g) gpu=${OPTARG};;
        l) gpuLocation=${OPTARG};;
        q) videoQuality=${OPTARG};;
        h) 
          if ! [[ ${OPTARG} == "elp" ]] ; then showInfo "Error: The \e[1mhelp\e[0m argument should be \e[1m-help\e[0m."; exit; else showHelp; exit; fi;;
        *) showInfo "Error: Invalid option selected!"; exit;;
    esac
done

if [[ ! ${codecs[@]} =~ $codec ]]
then 
  showHelp 'Error: The \e[1mCodec\e[0m value is incorrect i.e -c must be either "av1", "hevc" or "h264"!'
  exit 1
fi

echo
echo "#######################################################"
echo "#######################################################"
echo
echo -e "\e[1mPARAMETERS USED IN CONVERSION\e[0m"
echo
echo -e "Input file format                     =>  \e[1m$inputfiletype\e[0m"
echo -e "Output file format                    =>  \e[1m$outputfiletype\e[0m"
echo -e "Video codec                           =>  \e[1m$codec\e[0m"
echo -e "Remove original video?                =>  \e[1m$removeFile\e[0m"
echo -e "Video directory                       =>  \e[1m$path\e[0m"
echo -e "Using gpu?                            =>  \e[1m$gpu\e[0m"
echo -e "Gpu path                              =>  \e[1m$gpuLocation\e[0m"
echo -e "Video quality selected                =>  \e[1m${videoQuality:-'default'}\e[0m"
echo
echo "#######################################################"
echo "#######################################################"
echo

totalfiles=$(find "$path" -maxdepth 1 -name "*.$inputfiletype" | wc -l)
showInfo "There is \e[1m$totalfiles\e[0m video files in this folder with extension \e[1m$inputfiletype\e[0m."
declare -i count=0

if [[ $totalfiles -gt 0 ]]
then

  if [ ! -d "${path}CONVERTED" ]; then mkdir -p "${path}CONVERTED"; fi
  if [[ $removeFile == 'n' ]]
  then
    if [ ! -d "${path}ORIGINAL" ]; then mkdir -p "${path}ORIGINAL"; fi
  fi

  for file in "$path"*."$inputfiletype"
  do

    count+=1
    
    chargingState=$(upower -i "$(upower -e | grep '/battery')" | grep --color=never -E state|xargs|cut -d' ' -f2)
    batteryPower=$(upower -i "$(upower -e | grep '/battery')" | grep --color=never -E percentage|xargs|cut -d' ' -f2|sed s/%//)

    if [[ ${chargingStates[@]} =~ $chargingState ]] || [[ $batteryPower -gt 50 ]]
    then

      originalCode=$( ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file" )
      if [[ $originalCode = 'hevc'  ]] || [[ $originalCode = 'av1' ]]; then showInfo "Video already in $codec format. Skipping converting $file"; continue; fi

      
      fileSize=$( wc -c "$file" | awk '{print $1}' )
      
      showInfo "Started converting video file No. $count of $totalfiles titled \e[1m$file\e[0m, with file size \e[1m$fileSize\e[0m bytes."

      urlremoved="${file##*/}"
      filetyperemoved="${urlremoved%.*}"
      convertedFileAlreadyExists="n"
      
      if [[ $codec == "av1" ]]
      then
        showInfo "Converting using \e[1mav1\e[0m..."

        if [[ $gpu == "y" ]]
        then 
          showInfo "No gpu functionality for av1 conversion added yet! Use software decoder."
        else 
          {
            showInfo "COMMAND: time ffmpeg -hide_banner -loglevel verbose -i '$file' -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v libsvtav1 -preset 5 -crf ${videoQuality:-32} -g 240 -pix_fmt yuv420p10le -svtav1-params tune=0:film-grain=8 -c:a copy '${path}CONVERTED/${filetyperemoved}.${outputfiletype}'" && \
            time ffmpeg -hide_banner -loglevel verbose -i "$file" -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v libsvtav1 -preset 5 -crf "${videoQuality:-32}" -g 240 -pix_fmt yuv420p10le -svtav1-params tune=0:film-grain=8 -c:a copy "${path}CONVERTED/${filetyperemoved}.${outputfiletype}" && \
            moveOrDeleteFiles 
          } || continue
        fi

      elif [[ $codec == "hevc" ]]
      then 
        
        showInfo "Converting using \e[1mhevc\e[0m..."

        if [[ $gpu == "y" ]]
        then 
          {
            showInfo "COMMAND: time ffmpeg -hide_banner -loglevel verbose -hwaccel vaapi -hwaccel_device $gpuLocation -hwaccel_output_format vaapi -extra_hw_frames 30 -i '$file' -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v hevc_vaapi -qp ${videoQuality:-29} -pix_fmt yuv420p -profile:v main -preset slower -c:a copy '${path}CONVERTED/${filetyperemoved}.${outputfiletype}'" &&  \
            time ffmpeg -hide_banner -loglevel verbose -hwaccel vaapi -hwaccel_device "$gpuLocation" -hwaccel_output_format vaapi -extra_hw_frames 30 -i "$file" -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v hevc_vaapi -qp "${videoQuality:-29}" -pix_fmt yuv420p -profile:v main -preset slower -c:a copy "${path}CONVERTED/${filetyperemoved}.${outputfiletype}" && \
            moveOrDeleteFiles
          } || {
            showInfo "COMMAND: time ffmpeg -hide_banner -loglevel verbose -i '$file' -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v libx265 -pix_fmt yuv420p -profile:v main -preset medium -crf ${videoQuality:-27} -c:a copy '${path}CONVERTED/${filetyperemoved}.${outputfiletype}' -y" && \
            time ffmpeg -hide_banner -loglevel verbose -i "$file" -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v libx265 -pix_fmt yuv420p -profile:v main -preset medium -crf "${videoQuality:-27}" -c:a copy "${path}CONVERTED/${filetyperemoved}.${outputfiletype}" -y && \
            moveOrDeleteFiles
          } || continue
        else
          {
            showInfo "COMMAND: time ffmpeg -hide_banner -loglevel verbose -i '$file' -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v libx265 -pix_fmt yuv420p -profile:v main -preset slower -crf ${videoQuality:-27} -c:a copy '${path}CONVERTED/${filetyperemoved}.${outputfiletype}'" && \
            time ffmpeg -hide_banner -loglevel verbose -i "$file" -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v libx265 -pix_fmt yuv420p -profile:v main -preset slower -crf "${videoQuality:-27}" -c:a copy "${path}CONVERTED/${filetyperemoved}.${outputfiletype}" && \
            moveOrDeleteFiles
          } || continue
        fi

      else
        
        showInfo "Converting using \e[1mh264\e[0m..."

        if [[ $gpu == "y" ]]
        then 
          showInfo "No gpu functionality for h264 conversion added yet! Use software decoder."
        else
          {
            showInfo "COMMAND: time ffmpeg -hide_banner -loglevel verbose -i $file -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v libx264 -pix_fmt yuv420p -profile:v high -level 4.1 -preset slower -crf ${videoQuality:-22} -tune film -c:a copy ${path}CONVERTED/${filetyperemoved}.${outputfiletype}" && \
            time ffmpeg -hide_banner -loglevel verbose -i "$file" -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -c:v libx264 -pix_fmt yuv420p -profile:v high -level 4.1 -preset slower -crf "${videoQuality:-22}" -tune film -c:a copy "${path}CONVERTED/${filetyperemoved}.${outputfiletype}" && \
            moveOrDeleteFiles
          } || continue
        fi

      fi

    else 
      showInfo "Error: Battery power is \e[1m$batteryPower%\e[0m. EXiting script to save battery energy and protect it from overdraw."
      exit 1
    fi

  done

  if [ -d "${path}CONVERTED" ]; then rm -R "${path}CONVERTED"; fi

  showInfo "Finished converting \e[1m$count\e[0m of \e[1m$totalfiles\e[0m video files in this folder."

else
  showInfo "No files with extension \e[1m$inputfiletype\e[0m found so no conversion took place."
fi
