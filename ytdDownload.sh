#!/bin/bash

showHelp()
{
   # Display Help
   echo -e "\e[1mDownload video \e[0m"
   echo
   echo "Syntax: \e[1m bash ytDownload.sh [-u|v|f|a|s|help] \e[0m"
   echo "Options:"
   echo -e "\e[1m -u \e[0m     Video url"
   echo -e "\e[1m -o \e[0m     Output video format"
   echo -e "\e[1m -f \e[0m     Video format extension"
   echo -e '\e[1m -t \e[0m     Time duration to cut from video e.g. "*34:38-49:37" '
   echo -e '\e[1m -m \e[0m     File type dowmload mode i.e. either "video" of "audio" '
   echo -e '\e[1m -a \e[0m     Use aria2c to download i.e. pass "yes" to activate '
   echo -e "\e[1m -help \e[0m  Print this \e[1mhelp screen \e[0m"
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
#unset a

if [[ $1 == "" ]]; then echo "No options were passed"; exit; fi

# Default parameters
url=""
output="mp4"
video=""
timeOption=""
mode="video"
useAria2cDownloader="no"

while getopts u:o:f:t:m:a:h: option
do
	case "${option}" in
	u)  	
		if [[ -z "${OPTARG}" ]] ; then showInfo "Error: The \e[1mVideo url \e[0m value i.e -u is not set! "; exit; else url=${OPTARG}; fi ;;
  o)	output=${OPTARG} ;;
  f)
		if [[ -z ${OPTARG} ]] ; then showInfo "Error: The \e[1mVideo format \e[0m value i.e -f is is not set! "; exit; else video=${OPTARG}; fi ;;
  t) timeOption="--download-sections "${OPTARG}"" ;;
  m)
    if [[ ${OPTARG} == "video" ]] ||  [[ ${OPTARG} == "audio" ]]
    then mode=${OPTARG};
    else showInfo "Error: The \e[1mMode\e[0m value is incorrect i.e -m must be either "video" or "audio"! "; exit; 
    fi ;;
  a) 
    if [[ ${OPTARG} == "yes" ]] || [[ ${OPTARG} == "no" ]]
    then useAria2cDownloader=${OPTARG};
    else showInfo "Error: The \e[1mAria2c Downloader\e[0m activation value is incorrect i.e -a must be either "yes" or "no"! "; exit; 
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
echo -e "Url                             =>  \e[1m$url\e[0m "
echo -e "Output file extension           =>  \e[1m$output\e[0m "
echo -e "Input file format               =>  \e[1m$video\e[0m "
echo -e "File type download mode         =>  \e[1m$mode\e[0m "
echo -e "Time duration                   =>  \e[1m$timeOption\e[0m "
echo -e "Aria2c downloader               =>  \e[1m$useAria2cDownloader\e[0m "
echo
echo "#######################################################"
echo "#######################################################"
echo


audioExtensions=("3gp" "aa" "aac" "aax" "act" "aiff" "alac" "amr" "ape" "au" "awb" "dss" "dvf" "flac" "gsm" "iklax" "ivs" "m4a" "m4b" "m4p" "mmf" "movpkg" "mp3" "mpc" "msv" "nmf" "ogg" "oga" "mogg" "opus" "ra" "rm" "raw" "rf64" "sln" "tta" "voc" "vox" "wav" "wma" "wv" "webm" "8svx" "cda")
videoExtensions=("webm" "mkv" "vob" "ogv" "og" "drc" "gif" "gifv" "mng" "avi" "mt" "m2ts" "ts" "mov" "q" "wmv" "yuv" "rm" "rmvb" "viv" "asf" "amv" "mp4" "m4" "mpg" "mp2" "mpeg" "mpe" "mp" "m2v" "m4v" "svi" "3gp" "3g2" "mxf" "roq" "nsv" "flv" "f4v" "f4p" "f4a" "f4")

if [[ $mode == "video" ]] && [[ ${videoExtensions[@]} =~ $output ]]
then
  showInfo "The extension \e[1m$output\e[0m was found for \e[1m$mode\e[0m mode. Proceeding..."
elif [[ $mode == "audio" ]] && [[ ${audioExtensions[@]} =~ $output ]]
then 
  showInfo "The extension \e[1m$output\e[0m was found for \e[1m$mode\e[0m mode. Proceeding..."
else
  showInfo "The extension \e[1m$output\e[0m was not found for \e[1m$mode\e[0m mode. Please add the correct output extension for \e[1m$mode\e[0m file on parameter -o"; exit;
fi

fileName=$(yt-dlp -o "%(title)s^%(ext)s" --get-filename --no-download-archive "$url")
fileTitle=${fileName%^*}
fileExtension=${fileName#*^}

if [[ ${videoExtensions[@]} =~ $fileExtension ]] || [[ ${audioExtensions[@]} =~ $fileExtension ]]
then showInfo "Parsed files name is \e[1m$fileTitle.$fileExtension\e[0m"
else showInfo "The \e[1m$mode\e[0m extension \e[1m$fileExtension\e[0m was not parsed succesfully."; exit;
fi

showInfo "Downloading file \e[1m$fileTitle.$fileExtension\e[0m and converting it to be \e[1m$fileTitle.$output\e[0m..."

if [[ $mode == "video" ]]
then
  if [[ $useAria2cDownloader == "yes" ]]
  then time yt-dlp -i $timeOption --write-subs --sub-lang en --write-auto-sub --convert-subtitles srt --embed-metadata --abort-on-unavailable-fragment --fragment-retries 999 -o "$fileTitle-FILE.%(ext)s" --external-downloader aria2c --downloader-args aria2c:"-x 8 -k 2M" -f "$video" "$url"
  else time yt-dlp -i $timeOption --write-subs --sub-lang en --write-auto-sub --convert-subtitles srt --embed-metadata --abort-on-unavailable-fragment --fragment-retries 999 -o "$fileTitle-FILE.%(ext)s" -f "$video" "$url"
  fi

  if [[ -f "$fileTitle-FILE.en.srt" ]]
  then 
    showInfo "The subtitle file found is \e[1m $fileTitle-FILE.en.srt \e[0m"
    time ffmpeg  -i "$fileTitle-FILE.$fileExtension" -i "$fileTitle-FILE.en.srt" -c:s mov_text -metadata:s:s:0 language=eng -movflags use_metadata_tags -map_metadata 0 -vcodec copy -acodec copy "$fileTitle.$output"
    rm "$fileTitle-FILE.en.srt"
  else
    showInfo "No subtitle found..."
    time ffmpeg  -i "$fileTitle-FILE.$fileExtension" -movflags use_metadata_tags -map_metadata 0 -vcodec copy -acodec copy "$fileTitle.$output"
  fi
  rm "$fileTitle-FILE.$fileExtension"
elif [[ $mode == "audio" ]]
then
  if [[ $useAria2cDownloader == "yes" ]]
  then  time yt-dlp --audio-quality 0 --extract-audio --audio-format "$output" -o "%(title)s.%(ext)s" --add-metadata --convert-thumbnails jpg --embed-thumbnail --metadata-from-title "%(artist)s - %(title)s" --external-downloader aria2c --downloader-args aria2c:"-x 8 -k 2M" "$url"
  else  time yt-dlp --audio-quality 0 --extract-audio --audio-format "$output" -o "%(title)s.%(ext)s" --add-metadata --convert-thumbnails jpg --embed-thumbnail --metadata-from-title "%(artist)s - %(title)s" "$url"
  fi
fi

if [[ -f "$fileTitle.$output" ]]
then showInfo "File saved as \e[1m$fileTitle.$output\e[0m"
else showInfo "File \e[1m$fileTitle.$output\e[0m was not saved"
fi

showInfo "Finished!"