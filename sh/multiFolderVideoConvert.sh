#!/bin/bash

showInfo() {
  echo
  echo "======================================================="
  echo -e "${1}"
  echo "======================================================="
  echo
}

# parameters => path; ignoreFileFormat;
convertFolders () {
    showInfo() {
        echo
        echo "======================================================="
        echo -e "${1}"
        echo "======================================================="
        echo
    }

    # Will not run if no directories are available
    showInfo "Folder is '$1' and ignore is '${2}'"
    if [ -d "${1}" ]; then
        # convert using default format of mp4
        if [[ ${2} != "" ]]; then
            showInfo "Converting folder ${1} whilst ignoring original formats? => ${2}"
            bash videoConvert.sh -p "${1}" -f "${2}"
        else
            showInfo "Converting folder ${1}"
            bash videoConvert.sh -p "${1}"
        fi
       
        # loop though other formats
        formats=("mkv" "webm" "wmv" "mov" "ts" "mov" "mpg" "avi" "m4v")

        for format in "${formats[@]}";
        do
            if [[ ${2} != "" ]]; then
                showInfo "Converting folder ${1} whilst ignoring original formats? => ${2}"
                bash videoConvert.sh -p "${1}" -i "$format" -f "${2}"
            else
                showInfo "Converting folder ${1}"
                bash videoConvert.sh -p "${1}" -i "$format" 
            fi
        done
    else 
        showInfo "Folder ${1} does not exist"
    fi
}

export -f convertFolders

if [[ ${2} != "" ]]; then
    showInfo "Ignore video format is set to '$2'"
    if [ "${2}" == "yes" ] || [ "${2}" == "no" ] ; then 
        # $1 in find process becomes the file path represeneted by ${1}
        # pass additional parameter "ignoreOriginalFormat" i.e. ${2} 
        find "${1}" -maxdepth 5 -type d -exec bash -c 'convertFolders "$1" "$2"' _ {} "${2}" \;
    else 
        showInfo "Error: The \e[1mignore original format\e[0m value should either be \e[1myes\e[0m or \e[1mno\e[0m."
        exit
    fi
else 
    # $1 in find process becomes the file path represeneted by ${1}
    find "${1}" -maxdepth 5 -type d -exec bash -c 'convertFolders "$1"' _ {} \;
fi;