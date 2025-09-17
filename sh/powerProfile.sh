#!/bin/bash

showInfo() {
  echo
  echo "======================================================="
  echo -e "${1}"
  echo "======================================================="
  echo
}

if [[ ${1} == "" ]]
then
    showInfo 'Error: The \e[1mpower profile\e[0m option value is missing i.e it must be either \e[1mb\e[0m for balanced, \e[1mp\e[0m for performance or \e[1ms\e[0m for power-saver!'
    exit 1
fi

profile=${1}
profiles=("b" "p" "s" "l")
profileExists=0

for value in "${profiles[@]}"; do [[ "$profile" == "$value" ]] && profileExists=1; done

if [[ ${profileExists} == 0 ]]
then 
  showInfo 'Error: The \e[1mpower profile option\e[0m value is incorrect i.e it must be either \e[1mb\e[0m for balanced, \e[1mp\e[0m for performance, \e[1ms\e[0m for power-saver or \e[1ml\e[0m to show list of power profiles!'
  exit 1
fi

if [[ "$profile" == "b" ]]; then powerprofilesctl set balanced; showInfo "\e[1mBalanced\e[0m power profile selected"; powerprofilesctl list;
elif [[ "$profile" == "p" ]]; then powerprofilesctl set performance; showInfo "\e[1mPerformance\e[0m power profile selected"; powerprofilesctl list;
elif [[ "$profile" == "s" ]]; then powerprofilesctl set power-saver; showInfo "\e[1mPower Saver\e[0m power profile selected"; powerprofilesctl list;
elif [[ "$profile" == "l" ]]; then showInfo "\e[1mPower list states:\e[0m"; powerprofilesctl list;
fi 