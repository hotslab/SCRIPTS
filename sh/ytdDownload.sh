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
  echo -e "\e[1mDownload Video Help\e[0m"
  echo
  echo -e "Syntax: \e[1m bash ytDownload.sh [-u|v|f|a|s|help] \e[0m"
  echo
  echo "Options:"
  echo -e "\e[1m -u \e[0m     The \e[1mvideo url\e[0m to dowload from"
  echo -e "\e[1m -o \e[0m     The \e[1moutput format\e[0m for the video or audio e.g mp3 or mp4"
  echo -e "\e[1m -f \e[0m     The \e[1mvideo download format\e[0m extension e.g. -f 22 for 720p youtube video"
  echo -e '\e[1m -m \e[0m     The \e[1mfile type\e[0m download mode i.e. either "video" or "audio" '
  echo -e '\e[1m -a \e[0m     Use \e[1maria2c\e[0m to download i.e. pass "yes" to activate or "no" to deactivate '
  echo -e '\e[1m -t \e[0m     The \e[1mtime duration\e[0m to cut from video e.g. "*34:38-49:37" where format is "*HH:mm:ss-HH:mm:ss" '
  echo -e '\e[1m -n \e[0m     Use a \e[1mcustom file name\e[0m i.e. \e[1m "My Video" \e[0m'
  echo -e '\e[1m -b \e[0m     Select \e[1mbrowser\e[0m to use cookies from i.e. \e[1m "brave" \e[0m'
  echo -e '\e[1m -e \e[0m     Get \e[1mfile download extensions\e[0m to select from i.e. pass "yes" to fetch or "no" to progress normaly'
  echo -e '\e[1m -p \e[0m     Use the \e[1mpage title\e[0m from webpage to name the downloaded file i.e. "yes" or "no"'
  echo -e "\e[1m -help \e[0m  Print this \e[1mhelp screen \e[0m"
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

cleanUp() {
  showInfo "Script externaly stopped! Exiting download process gracefully..."
  exit 1
}

trap cleanUp INT SIGINT SIGTERM

#unset u
#unset f
#unset h
#unset t
#unset m
#unset a
#unset n
#unset b
#unset e

if [[ -v $1 ]]; then showHelp "No options were passed"; exit 1; fi

# Default parameters
url=""
video=""
output="mp4"
mode="video"
useAria2cDownloader="no"
timeOption=""
customName=""
browser="none"
getExtensions="no"
pageTitleName="no"

while getopts u:e:o:f:m:a:t:n:b:p:h: option
do
  case "${option}" in
  u)  url=${OPTARG} ;;
  e)  getExtensions=${OPTARG} ;;
  o)	output=${OPTARG} ;;
  f)  video=${OPTARG} ;;
  m)
    if [[ ${OPTARG} == "video" ]] ||  [[ ${OPTARG} == "audio" ]]
    then mode=${OPTARG};
    else showHelp "Error: The \e[1mMode\e[0m value is incorrect i.e -m must be either \e[1mvideo\e[0m or \e[1maudio\e[0m! "; exit 1; 
    fi ;;
  a) 
    if [[ ${OPTARG} == "yes" ]] || [[ ${OPTARG} == "no" ]]
    then useAria2cDownloader=${OPTARG};
    else showHelp "Error: The \e[1mAria2c Downloader\e[0m activation value is incorrect i.e -a must be either \e[1myes\e[0m or \e[1mno\e[0m! "; exit 1; 
    fi ;;
  t)  timeOption="--download-sections ${OPTARG}" ;;
  n)  customName=${OPTARG} ;;
  b)  
    if [[ ${OPTARG} != "none" ]]; then browser=${OPTARG}; fi ;;
  p)  
    if [[ ${OPTARG} == "yes" ]] || [[ ${OPTARG} == "no" ]]
    then pageTitleName=${OPTARG};
    else showHelp "Error: The \e[1mPage Title\e[0m option value is incorrect i.e -a must be either \e[1myes\e[0m or \e[1mno\e[0m! "; exit 1; 
    fi ;;
  h) 
    if ! [[ ${OPTARG} == "elp" ]] ; then showHelp "Error: The \e[1mhelp\e[0m argument should be \e[1m-help\e[0m."; exit 1; else showHelp; exit 1; fi;;
  *) 	showHelp "Error: Invalid option selected!"; exit 1;;
  esac
done

if [[ $url == "" ]]; then showHelp "Error: The \e[1mVideo url \e[0m value is not set i.e -u "; exit 1; fi

if [[ $getExtensions == "yes" ]]
then
  if [[ $browser == "none" ]]
  then time yt-dlp -F4 "$url"; exit 1;
  else time yt-dlp -F4 --cookies-from-browser "$browser"  "$url"; exit 1;
  fi 
elif [[ $getExtensions != "no" ]]
then 
  showHelp "Error: The \e[1mExtensions\e[0m value is incorrect i.e -e must be either \e[1myes\e[0m or \e[1mno\e[0m! "; exit 1; 
fi

if [[ $output == "" ]]; then showHelp "Error: The \e[1mOutput format  \e[0m is not set i.e -m "; exit 1; fi

if [[ $video == "" ]] && [[ $mode == "video" ]]; then showHelp "Error: The \e[1mVideo format \e[0m value is not set i.e -f "; exit 1; fi

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
echo -e "Aria2c downloader               =>  \e[1m$useAria2cDownloader\e[0m "
if ! [[ $timeOption == "" ]]; then echo -e "Time duration                   =>  \e[1m$timeOption\e[0m "; fi
if ! [[ $customName == "" ]]; then echo -e "Custom name                     =>  \e[1m$customName\e[0m "; fi
echo -e "Browser                         =>  \e[1m$browser\e[0m "
echo -e "Download Extensions             =>  \e[1m$getExtensions\e[0m "
echo -e "Use Page Title                  =>  \e[1m$pageTitleName\e[0m "
echo
echo "#######################################################"
echo "#######################################################"
echo


audioExtensions=("3gp" "aa" "aac" "aax" "act" "aiff" "alac" "amr" "ape" "au" "awb" "dss" "dvf" "flac" "gsm" "iklax" "ivs" "m4a" "m4b" "m4p" "mmf" "movpkg" "mp3" "mpc" "msv" "nmf" "ogg" "oga" "mogg" "opus" "ra" "rm" "raw" "rf64" "sln" "tta" "voc" "vox" "wav" "wma" "wv" "webm" "8svx" "cda" "wav" "webm")
videoExtensions=("webm" "mkv" "vob" "ogv" "og" "drc" "gif" "gifv" "mng" "avi" "mt" "m2ts" "ts" "mov" "q" "wmv" "yuv" "rm" "rmvb" "viv" "asf" "amv" "mp4" "m4" "mpg" "mp2" "mpeg" "mpe" "mp" "m2v" "m4v" "svi" "3gp" "3g2" "mxf" "roq" "nsv" "flv" "f4v" "f4p" "f4a" "f4")

if [[ $mode == "video" ]] && [[ ${videoExtensions[@]} =~ $output ]]
then
  showInfo "The extension \e[1m$output\e[0m was found for \e[1m$mode\e[0m mode. Proceeding..."
elif [[ $mode == "audio" ]] && [[ ${audioExtensions[@]} =~ $output ]]
then 
  showInfo "The extension \e[1m$output\e[0m was found for \e[1m$mode\e[0m mode. Proceeding..."
else
  showInfo "The extension \e[1m$output\e[0m was not found for \e[1m$mode\e[0m mode. Please add the correct output extension for \e[1m$mode\e[0m file on parameter -o"; exit 1;
fi

fileName=""

if [[ $mode == "video" ]]
then
  if [[ $browser == "none" ]]
  then fileName=$(yt-dlp -4 -o "%(title)s^%(ext)s" -f "$video" --get-filename --skip-download "$url")
  else fileName=$(yt-dlp -4 -o "%(title)s^%(ext)s" -f "$video" --get-filename --skip-download --cookies-from-browser "$browser" "$url")
  fi
else 
  if [[ $browser == "none" ]]
  then fileName=$(yt-dlp -4 --get-filename --audio-quality 0 --extract-audio --audio-format "$output" -o "%(title)s^%(ext)s" "$url")
  else fileName=$(yt-dlp -4 --get-filename --audio-quality 0 --extract-audio --audio-format "$output" -o "%(title)s^%(ext)s" --cookies-from-browser "$browser" "$url")
  fi
fi

fileTitle=$([[ $customName == "" ]] && echo "${fileName%^*}" || echo "$customName")
fileExtension=${fileName#*^}

if [[ ${videoExtensions[@]} =~ $fileExtension ]] || [[ ${audioExtensions[@]} =~ $fileExtension ]]
then showInfo "Parsed files name is \e[1m$fileTitle.$fileExtension\e[0m"
else showInfo "The \e[1m$mode\e[0m extension \e[1m$fileExtension\e[0m was not parsed succesfully."; exit 1;
fi

if [[ $pageTitleName == "yes" ]] 
then 
  titleFound=$(wget --quiet -O - "$url" | paste -s -d ' '  | sed -n -e 's!.*<head[^>]*>\(.*\)</head>.*!\1!p' | sed -n -e 's!.*<title>\(.*\)</title>.*!\1!p' | sed -e 's/\///g' -e 's/|//g' -e 's/\s*,\s*/,/g' -e 's/^\s*//' -e 's/\s*$//')
  if [[ $titleFound == "" ]]
  then showInfo "The page title was not found so using the default name of \e[1m$fileTitle\e[0m."
  else showInfo "Using the new name of \e[1m$titleFound\e[0m found on page title instead of \e[1m$fileTitle\e[0m."; fileTitle=$titleFound; 
  fi
fi

showInfo "Downloading file \e[1m$fileTitle.$fileExtension\e[0m and converting it to be \e[1m$fileTitle.$output\e[0m..."

if [[ $mode == "video" ]]
then
  if [[ $useAria2cDownloader == "yes" ]]
  then 
    if [[ $browser == "none" ]]
    then 
      # shellcheck disable=SC2086
      time yt-dlp -i4 $timeOption --write-subs --sub-lang en --write-auto-sub --convert-subtitles srt --embed-metadata --abort-on-unavailable-fragment --fragment-retries 999 -o "$fileTitle-FILE.%(ext)s" --external-downloader aria2c --downloader-args aria2c:"-x 8 -k 2M" -f "$video" "$url";
    else 
      # shellcheck disable=SC2086
      time yt-dlp -i4 $timeOption --cookies-from-browser "$browser" --write-subs --sub-lang en --write-auto-sub --convert-subtitles srt --embed-metadata --abort-on-unavailable-fragment --fragment-retries 999 -o "$fileTitle-FILE.%(ext)s" --external-downloader aria2c --downloader-args aria2c:"-x 8 -k 2M" -f "$video" "$url";
    fi
  else 
    if [[ $browser == "none" ]]
    then 
      # shellcheck disable=SC2086
      time yt-dlp -i4 $timeOption --write-subs --sub-lang en --write-auto-sub --convert-subtitles srt --embed-metadata --abort-on-unavailable-fragment --fragment-retries 999 -o "$fileTitle-FILE.%(ext)s" -f "$video" "$url";
    else 
      # shellcheck disable=SC2086
      time yt-dlp -i4 $timeOption --cookies-from-browser "$browser" --write-subs --sub-lang en --write-auto-sub --convert-subtitles srt --embed-metadata --abort-on-unavailable-fragment --fragment-retries 999 -o "$fileTitle-FILE.%(ext)s" -f "$video" "$url";
    fi
  fi
  if [[ $timeOption == "" ]]
  then
    showInfo "TEST"
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
  else
    showInfo "The time option i.e \e[1m -t $timeOption \e[0m was selected so \e[1m $output \e[0m format was ignored, and the original file extension \e[1m $fileExtension \e[0m was used instead."
    if [[ -f "$fileTitle-FILE.en.srt" ]]
    then showInfo "Subitle file exists named $fileTitle-FILE.en.srt. Please manually add them to the file if needed and delete the file."
    fi
    mv "$fileTitle-FILE.$fileExtension" "$fileTitle.$fileExtension" 
  fi
elif [[ $mode == "audio" ]]
then
  if [[ $useAria2cDownloader == "yes" ]]
  then  
    if [[ $browser == "none" ]]
    then time yt-dlp -4 "$timeOption" --audio-quality 0 --extract-audio --audio-format "$output" -o "$fileTitle.$output" --embed-metadata --convert-thumbnails jpg --embed-thumbnail --external-downloader aria2c --downloader-args aria2c:"-x 8 -k 2M" -f "$video" "$url"
    else time yt-dlp -4 "$timeOption" --cookies-from-browser "$browser" --audio-quality 0 --extract-audio --audio-format "$output" -o "$fileTitle.$output" --embed-metadata --convert-thumbnails jpg --embed-thumbnail --external-downloader aria2c --downloader-args aria2c:"-x 8 -k 2M" -f "$video" "$url"
    fi
  else  
    if [[ $browser == "none" ]]
    then time yt-dlp -4 "$timeOption" --audio-quality 0 --extract-audio --audio-format "$output" -o "$fileTitle.$output" --embed-metadata --convert-thumbnails jpg --embed-thumbnail -f "$video" "$url"
    else time yt-dlp -4 "$timeOption" --cookies-from-browser "$browser" --audio-quality 0 --extract-audio --audio-format "$output" -o "$fileTitle.$output" --embed-metadata --convert-thumbnails jpg --embed-thumbnail -f "$video" "$url"
    fi
  fi
fi

if [[ -f "$fileTitle.$output" ]]
then showInfo "File saved as \e[1m$fileTitle.$output\e[0m"
else showInfo "File \e[1m$fileTitle.$output\e[0m was not saved"
fi

showInfo "Finished!"
exit 0