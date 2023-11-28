#!/bin/bash

mkdir -p "CON"

for file in *.ts; do echo "Processing $file"; mkvmerge -o "CON/${file%.*}.mkv" "$file"; done