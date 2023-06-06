#!/bin/bash

showHelp()
{
   # Display Help
   echo -e "\e[1mDownload video \e[0m"
   echo
   echo "Syntax: bash convert.sh [-d|i|o|v|a|s|r|help]"
   echo "Options:"
   echo -e "-u     Video url"
   echo -e "-v     Video format number"
   echo -e "-f     Video format extension"
   echo -e "-a     Audio format number"
   echo -e "-s     Audio format extension"
   echo -e "-help  Print this \e[1mhelp screen \e[0m"
   echo
}

showInfo() {
  echo
  echo "======================================================="
  echo -e ${1}
  echo "======================================================="
  echo
}

#unset u
#unset v
#unset a
#unset h

if [[ $1 == "" ]]; then echo "No options were passed"; exit; fi

# Default parameters
url=""
video=""
videoFormat="webm"
audio=""
audioFormat="webm"

while getopts u:v:f:a:s:h: option
do
	case "${option}" in
	u)  	
		if [[ -z "${OPTARG}" ]] ; then showInfo "Error: The \e[1mVideo url \e[0m value i.e -s is not set!"; exit; else url=${OPTARG}; fi ;;
        v)
		if ! [[ ${OPTARG} =~ $re ]] ; then showInfo "Error: The \e[1mVideo ID\e[0m value i.e -s is empty or not a number!"; exit; else video=${OPTARG}; fi ;;
	f)	videoFormat=${OPTARG} ;;
        a) 
		if ! [[ ${OPTARG} =~ $re ]] ; then showInfo "Error: The \e[1mAudio ID\e[0m value i.e -s is empty or not a number!"; exit; else audio=${OPTARG}; fi ;;
	s)	audioFormat=${OPTARG} ;;
        h) 
          	if ! [[ ${OPTARG} == "elp" ]] ; then showInfo "Error: The \e[1mhelp\e[0m argument should be \e[1m-help\e[0m."; exit; else showHelp; exit; fi;;
        *) 	showInfo "Error: Invalid option selected!"; exit;;
    esac
done

echo
echo "#######################################################"
echo "#######################################################"
echo
echo "PARAMETERS USED IN CONVERSION "
echo
echo "Video url                             =>  $url"
echo "Video file format ID                  =>  $video"
echo "Video file extension                  =>  $videoFormat"
echo "Audio file format ID                  =>  $audio"
echo "Video file extension                  =>  $videoFormat"
echo
echo "#######################################################"
echo "#######################################################"
echo


filename=$(yt-dlp -o "%(title)s" --get-filename --no-download-archive "$url")

showInfo "Filename is $filename"

showInfo "Downloading video file with command yt-dlp -i -o $filename-video.$videoFormat -f $video  $url"

yt-dlp -i -o "$filename-video.$videoFormat" -f "$video"  "$url"

showInfo "Downloading audio file with command yt-dlp -i -o $filename-audio.$audioFormat -f $audio  $url"

yt-dlp -i -o "$filename-audio.$audioFormat" -f "$audio"  "$url"

mkvmerge -o "$filename.mkv" "$filename-video.$videoFormat" "$filename-audio.$audioFormat"

rm "$filename-video.$videoFormat" "$filename-audio.$audioFormat"

showInfo "Video saved as $filename.mkv"
