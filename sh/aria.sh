#!/bin/bash

set -e 

showInfo() {
    echo
    echo    "=============================================================="
    echo    -e ${1}
    echo    "=============================================================="
    echo
}

cleanUp() {
    showInfo "Script externally stopped! Exiting download process gracefully..."
    exit 1
}

trap cleanUp INT SIGINT SIGTERM

if [ ! -f "${HOME}/ariadownloads.txt" ]; then touch "${HOME}/ariadownloads.txt"; fi

aria2c --input-file="${HOME}/ariadownloads.txt" --save-session="${HOME}/ariadownloads.txt" --save-session-interval=600 --enable-rpc 