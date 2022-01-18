#!/bin/bash

showHelp()
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
   echo -e "-x    Convert video frames - default is \e[1m no \e[0m"
   echo -e "-f    Video frames per second (fps) .e.g 24 or 60 - default is \e[1m 24 \e[0m"
   echo -e "-l    Limit range for fps to be converted .e.g 24 - default is \e[1m 0 \e[0m"
   echo -e "-help  Print this \e[1m Help Screen \e[0m"
   echo
}

showInfo() {
  echo
  echo "======================================================="
  echo -e ${1}
  echo "======================================================="
  echo
}

roundNumber() {
  printf "%.${2}f" "${1}"
}

# Default parameters
directory="$(pwd)/"
inputfiletype="mp4"
outputfiletype="mp4"
videocodec="libx265 -crf 30"
audiocodec="aac -ab 128k -ar 44100"
scale=1080
removefolders="no"
changefps="no"
newFPS=24
fpsLimit=0

while getopts d:i:o:v:a:s:r:f:x:l:h: option
do
	case "${option}" in
        d)
          folder=${OPTARG}
          if ! [[ $folder == */ ]]; then folder="$folder/"; showInfo "String has been changed to $folder"; fi 
          if [ ! -d "$folder" ]; then showInfo "Error: The $folder directory does not exist!"; exit; else directory=$folder; fi ;;
        i) inputfiletype=${OPTARG};;
        o) outputfiletype=${OPTARG};;
        v) videocodec=${OPTARG};;
        a) audiocodec=${OPTARG};;
        s)
          re='^[0-9]+$'
          if ! [[ ${OPTARG} =~ $re ]] ; then showInfo "Error: The \e[1mscale\e[0m value i.e -s is empty or not a number!"; exit; else scale=${OPTARG}; fi ;;
        r) 
          if [ ${OPTARG} == "yes" ] || [ ${OPTARG} == "no" ] ; then removefolders=${OPTARG}; else showInfo "Error: The \e[1mremove folder\e[0m value should either be \e[1myes\e[0m or \e[1mno\e[0m."; exit; fi ;;
        x)
          if [ ${OPTARG} == "yes" ] || [ ${OPTARG} == "no" ] ; then changefps=${OPTARG}; else showInfo "Error: The value to change fps should either be \e[1myes\e[0m or \e[1mno\e[0m."; exit; fi ;;
        f)
          re='^[0-9]+$'
          if ! [[ ${OPTARG} =~ $re ]] ; then showInfo "Error: The \e[1mfpsvalue\e[0m i.e \e[1m-f\e[0m is empty or not a number!";  exit; else newFPS=${OPTARG}; fi ;;
        l)
          re='^[0-9]+$'
          if ! [[ ${OPTARG} =~ $re ]] ; then showInfo "Error: The \e[1mfpslimit value\e[0m i.e \e[1m-l\e[0m is empty or not a number!"; exit; else fpsLimit=${OPTARG}; fi ;;
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
echo "Video directory                       =>  $directory"
echo "Input file format                     =>  $inputfiletype"
echo "Output file format                    =>  $outputfiletype"
echo "Video codec                           =>  $videocodec"
echo "Audio codec                           =>  $audiocodec"
echo "Video dimension scale                 =>  $scale"
echo "Remove conversion folders?            =>  $removefolders"
echo "Convert video frames?                 =>  $changefps"
echo "Video frames per second               =>  $newFPS"
echo "Limit range for fps to be converted   =>  $fpsLimit"
echo
echo "#######################################################"
echo "#######################################################"
echo

totalfiles=$(find "$directory" -maxdepth 1 -name "*.$inputfiletype" | wc -l)
showInfo "There is $totalfiles video files in this folder."
declare -i count=0

if [[ $totalfiles -gt 0 ]]; then
  if [ ! -d "$directory/CON" ]; then mkdir -p "$directory/CON"; fi
  if [ ! -d "$directory/DONE" ]; then mkdir -p "$directory/DONE"; fi
 
  while IFS= read -r -d '' i; 
  do
    count+=1

    showInfo "Started converting video file No. $count of $totalfiles titled '$i'..."
    height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 "$i")
    width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$i")
    showInfo "Height and width of '$i' is: height = $height and width = $width "
    fpsData=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=s=x:p=0 "$i")

    OLDIFS=$IFS

    IFS='/' read -ra originalFPSArray <<< "$fpsData"
    showInfo "Video's original fps data is ${originalFPSArray[0]}/${originalFPSArray[1]}"
    originalFPS=$(bc -l <<< "(${originalFPSArray[0]} / ${originalFPSArray[1]})")
    originalFPS=$(roundNumber ${originalFPS} 0)
    showInfo "Calculated video framerate is $originalFPS"

    IFS=$OLDIFS

    urlremoved="${i##*/}"
    filetyperemoved="${urlremoved%.*}"

    if [[ "${urlremoved}" != *-converted.${inputfiletype} ]]; then
      if  [ $height -gt $scale ] || [ $width -gt $scale ]; then
        if [ $width -gt $height ]; then
          showInfo "Changing dimensions by width..."
          truncated=$(bc -l <<< "($height / $width) * $scale")
          truncated=$(( ((${truncated%.*}+5)/10)*10 ))
          showInfo "Width truncated to $truncated"

          if [ ${changefps} == "yes" ] && [ $originalFPS -ge $fpsLimit ] && [ $originalFPS -ne $newFPS ]; then
            showInfo "Video fps changed to $newFPS from $originalFPS..."
            ffmpeg -y -i "$i" -filter:v fps=fps="${newFPS}" -vf scale="${scale}:${truncated}" -c:v $videocodec -c:a $audiocodec "${directory}CON/${filetyperemoved}-converted.${outputfiletype}" < /dev/null
          else
            showInfo "Video fps of $originalFPS is unchanged..."
            ffmpeg -y -i "$i" -vf scale="${scale}:${truncated}" -c:v $videocodec -c:a $audiocodec "${directory}CON/${filetyperemoved}-converted.${outputfiletype}" < /dev/null
          fi
        else
          showInfo "Changing dimensions by height..."
          truncated=$(bc -l <<< "($width / $height) * $scale")
          truncated=$(( ((${truncated%.*}+5)/10)*10 ))
          showInfo "Height truncated to $truncated"

          if [ ${changefps} == "yes" ] && [ $originalFPS -ge $fpsLimit ] && [ $originalFPS -ne $newFPS ]; then
            showInfo "Video fps changed to $newFPS from $originalFPS..."
            ffmpeg -y -i "$i" -filter:v fps=fps="${newFPS}" -vf scale="${truncated}:${scale}" -c:v $videocodec -c:a $audiocodec "${directory}CON/${filetyperemoved}-converted.${outputfiletype}" < /dev/null
          else
            showInfo "Video fps of $originalFPS is unchanged..."
            ffmpeg -y -i "$i" -vf scale="${truncated}:${scale}" -c:v $videocodec -c:a $audiocodec "${directory}CON/${filetyperemoved}-converted.${outputfiletype}" < /dev/null
          fi
        fi
      else
        showInfo "No dimensions have been changed."

        if [ ${changefps} == "yes" ] && [ $originalFPS -ge $fpsLimit ] && [ $originalFPS -ne $newFPS ]; then
          showInfo "Video fps changed to $newFPS from $originalFPS..."
          ffmpeg -y -i "$i" -filter:v fps=fps="${newFPS}" -c:v $videocodec -c:a $audiocodec "${directory}CON/${filetyperemoved}-converted.${outputfiletype}" < /dev/null
        else
          showInfo "Video fps of $originalFPS is unchanged..."
          ffmpeg -y -i "$i" -c:v $videocodec -c:a $audiocodec "${directory}CON/${filetyperemoved}-converted.${outputfiletype}" < /dev/null
        fi
      fi

      mv "$i" "${directory}DONE/${urlremoved}"
      showInfo "The video file No. $count of $totalfiles titled '$i' has been converted to the CON folder, and the original file moved to the DONE folder."

    else
      showInfo "The video file No. $count of $totalfiles titled '$i' was already converted. No further action done on the file."
    fi
  done < <(find "$directory" -maxdepth 1 -name "*.$inputfiletype" -print0)
  unset IFS

  if [ $removefolders == "yes" ] && [ $totalfiles -eq $count ]; then
    if [ -d "$directory/CON" ]; then mv ${directory}CON/* "$directory"; rm -R "${directory}CON"; fi
    if [ -d "$directory/DONE" ]; then rm -R "${directory}DONE"; fi
  fi

  showInfo "Finished converting $count of $totalfiles video files in this folder."

else
  echo "No files with extension $inputfiletype found so no conversion took place."
fi
