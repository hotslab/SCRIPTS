#!/bin/bash

showInfo() {
  echo
  echo "======================================================="
  echo -e ${1}
  echo "======================================================="
  echo
}

for wavFile in *.wav 
  do
    showInfo "Processing wav file $wavFile"
    # /usr/local/bin/python3.10 -m demucs -n 83fc094f "$wavFile"
    /usr/local/bin/python3.10 -m demucs -n mdx_extra "$wavFile"
done