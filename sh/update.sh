#!/bin/bash

echo " "
echo "Checking updates for apt packages..."
echo " "
sudo apt update
echo " "
echo "Upgradable apt packages..."
echo " "
sudo apt list --upgradable -a
echo " "
echo "Checking updates for flatpack packages..."
echo " "
flatpak remote-ls --updates -vv
