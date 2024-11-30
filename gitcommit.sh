#!/bin/bash

showInfo() {
  echo
  echo "======================================================="
  echo -e ${1}
  echo "======================================================="
  echo
}

if [[ $1 == "" ]]; then showInfo "Commit message was not passed!"; exit 1; fi

message=${1}

git add . && git commit -m "$message" && git push