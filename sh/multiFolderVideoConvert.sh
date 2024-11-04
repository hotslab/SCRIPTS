#!/bin/bash

showInfo() {
  echo
  echo "======================================================="
  echo -e ${1}
  echo "======================================================="
  echo
}

path=${1}

convertFolders () {
    if [ -d "${1}" ]; then
        # Will not run if no directories are available
        showInfo "Converting folder ${1}"
        bash videoConvert.sh -p "${1}"
        bash videoConvert.sh -p "${1}" -i mkv
        bash videoConvert.sh -p "${1}" -i webm
        bash videoConvert.sh -p "${1}" -i wmv
        bash videoConvert.sh -p "${1}" -i mov
        bash videoConvert.sh -p "${1}" -i ts
    else 
        showInfo "Folder ${1} does not exist"
    fi
}

export -f convertFolders

find "$path" -maxdepth 5 -type d -exec bash -c 'convertFolders "$0"' {} \;
