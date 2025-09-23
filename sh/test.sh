#!/bin/bash

showInfo() {
  echo
  echo "======================================================="
  echo -e "${1}"
  echo "======================================================="
  echo
}

test=$(wget --quiet -O - "$1" \
| paste -s -d ' '  \
| sed -n -e 's!.*<head[^>]*>\(.*\)</head>.*!\1!p' \
| sed -n -e 's!.*<title>\(.*\)</title>.*!\1!p' \
| sed -e 's/\///g' -e 's/|//g' \
| sed -e's/\(.\{255\}\).*/\1/' \
| sed -e 's/\s*,\s*/,/g' -e 's/^\s*//' -e 's/\s*$//'
)

# test2=$(echo "$test" | sed -e's/\(.\{255\}\).*/\1__/' | sed -e 's/\///g' -e 's/|//g' -e 's/\s*,\s*/,/g' -e 's/^\s*//' -e 's/\s*$//')

showInfo "$test.mp4"

# showInfo "$test2.mp4"