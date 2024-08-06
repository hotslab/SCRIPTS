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

aria2c --enable-rpc