#!/bin/bash

set -e 

showInfo() {
  echo
  echo "======================================================="
  echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] ${1}"
  echo "======================================================="
  echo
}

cleanUp() {
    showInfo "Script externally stopped! Exiting download process gracefully..."
    exit 1
}

get_links() {
    local newCursor=""
    # 1. Base Case: Check for the stopping condition
    if [[ "$1" == "" || "$2" == ""  ]]; then
        showInfo "The url or username is missing. Stopped recursive function!"
    else 
        # 2. Logic: Perform some work
        showInfo "Processing links for user \e[1m$2\e[0m with url \e[1m$1\e[0m"
        
        curl -H "Authorization: Bearer $CIVITAI_API_KEY" \
            "https://civitai.com/api/v1/images?username=${1}&type=video&period=AllTime&nsfw=true&limit=100&cursor=${2}" \
            | grep -Po '"url":\s*"\K[^"]*' \
            >> "$1.txt" # Append links to file 

        newCursor=$(
            curl -H "Authorization: Bearer $CIVITAI_API_KEY" \
                "https://civitai.com/api/v1/images?username=${1}&type=video&period=AllTime&nsfw=true&limit=100&cursor=${2}" \
                | grep -Po '"nextCursor":\s*"\K[^"]*'  \
                || true # Prevents cript from crashing due to setting set -e 
        )

        showInfo "THE NEW CURSOR IS $newCursor"

        # 3. Recursive Step: Call the function again with updated arguments
        if [[ ! -z $newCursor && $newCursor != ""  ]]; then
            showInfo "Found the next page links for user \e[1m$1\e[0m with url \e[1m$newCursor\e[0m"
            get_links "$1" "$newCursor"
        else
            showInfo "No next page found. Ending gathering links for user \e[1m$1\e[0m..."
        fi
    fi

}

trap cleanUp INT SIGINT SIGTERM

if [ -f .env ]; then
    set -a            # Automatically export all variables
    source .env       # Load the variables
    set +a            # Stop automatically exporting
else
    showInfo "The .env file was not found containing the authourisation code!"
    exit 1
fi

if [[ $CIVITAI_API_KEY == "" ]]; then
    showInfo "The .env CIVIT_API_KEY variable is empty. Unable to proceed"
    exit 1
fi

# DEFAULTS
userName="" 
currentCusor=1

if [[ ${1} == "" ]]
then
    showInfo "Error: The \e[1musername\e[0m value is missing or empty!"
    exit 1
else
    userName="${1}"
fi

if [ -f "$userName.txt" ]; then
    rm "$userName.txt"
else 
    touch "$userName.txt"
fi

get_links "$userName" $currentCusor

showInfo "Downloading files for $userName..."

if [ ! -d "$userName" ]; then mkdir "$userName"; fi

yt-dlp -a "$userName.txt" -o "$userName/$userName-%(autonumber)s.%(ext)s" --embed-metadata --abort-on-unavailable-fragment --fragment-retries 999 --sleep-interval 1
showInfo "Finished downloading files for \e[1m$userName\e[0m!"