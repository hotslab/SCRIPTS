#!/bin/bash

showInfo() {
  echo
  echo "======================================================="
  echo -e ${1}
  echo "======================================================="
  echo
}

if [[ $1 == "" ]]; then echo "No video url was passed."; exit; fi

index=0

# $@ represents variables passed in command
for url in "$@"
do	
	index=$((index+1))
	showInfo "$index. Downloading with command => yt-dlp -f 1800 -o %(title)s.%(ext)s --abort-on-unavailable-fragment --fragment-retries 999 $url"
	yt-dlp -f 1800 -o "%(title)s.%(ext)s" --abort-on-unavailable-fragment --fragment-retries 999 "$url"
done