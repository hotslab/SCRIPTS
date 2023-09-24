#!/bin/bash

showHelp()
{
   # Display Help
   echo -e "\e[1mDownload video \e[0m"
   echo
   echo "Syntax: bash ytDownload.sh [-u|v|f|a|s|help]"
   echo "Options:"
   echo -e "-u     Video url"
   echo -e "-o     Output video format"
   echo -e "-f     Video format extension"
   echo -e '-t     Time duration to cut from video e.g. "*34:38-49:37"'
   echo -e '-m     File type dowmload mode i.e. either "video" of "audio" '
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
#unset f
#unset h
#unset t
#unset m

if [[ $1 == "" ]]; then echo "No options were passed"; exit; fi

# Default parameters
url=""
output="mp4"
video=""
timeOption=""
mode="video"

while getopts u:o:f:t:m:h: option
do
	case "${option}" in
	u)  	
		if [[ -z "${OPTARG}" ]] ; then showInfo "Error: The \e[1mVideo url \e[0m value i.e -u is not set!"; exit; else url=${OPTARG}; fi ;;
  o)	output=${OPTARG} ;;
  f)
		if [[ -z ${OPTARG} ]] ; then showInfo "Error: The \e[1mVideo format \e[0m value i.e -f is is not set!"; exit; else video=${OPTARG}; fi ;;
  t) timeOption="--download-sections "${OPTARG}"" ;;
  m)
    if [[ ${OPTARG} == "video" ]] ||  [[ ${OPTARG} == "audio" ]]
      then mode=${OPTARG};
      else showInfo "Error: The \e[1mMode\e[0m value is incorrect i.e -m must be either video or audio!"; exit; 
    fi ;; 
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
echo "Url                             =>  $url"
echo "Output file extension           =>  $output"
echo "Input file format               =>  $video"
echo "File type download mode         =>  $mode"
echo "Time duration                   =>  $timeOption"
echo
echo "#######################################################"
echo "#######################################################"
echo

filename=$(yt-dlp -o "%(title)s" --get-filename --no-download-archive "$url")

if [[ $mode == "video" ]]
  then
    fileExtension=$(yt-dlp -o "%(ext)s" -f "$video" --get-filename --no-download-archive "$url")
    showInfo "Downloading $filename with extention $fileExtension..."
    time yt-dlp -i $timeOption --write-subs --sub-lang en --write-auto-sub --convert-subtitles srt --embed-metadata --abort-on-unavailable-fragment --fragment-retries 999 -o "$filename-FILE.%(ext)s" -f "$video" "$url"
    if [[ -f "$filename-FILE.en.srt" ]]
      then 
        showInfo "The subtitle file found is $filename-FILE.en.srt"
        time ffmpeg  -i "$filename-FILE.$fileExtension" -i "$filename-FILE.en.srt" -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -vcodec copy -acodec copy "$filename.$output"
        rm "$filename-FILE.en.srt"
    else
      showInfo "No subtitle found..."
      time ffmpeg  -i "$filename-FILE.$fileExtension" -movflags use_metadata_tags -map_metadata 0 -vcodec copy -acodec copy "$filename.$output"
    fi
    rm "$filename-FILE.$fileExtension"
elif [[ $mode == "audio" ]]
  then
    time yt-dlp --audio-quality 0 --extract-audio --audio-format "$output" -o "%(title)s.%(ext)s" --add-metadata --embed-thumbnail --metadata-from-title "%(artist)s - %(title)s" "$url"
fi

showInfo "File saved as $filename.$output"
