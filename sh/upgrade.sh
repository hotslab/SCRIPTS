#!/bin/bash

echo " " && \
    echo "Upgrading apt packages..." && \
    echo " " && \
    sudo apt upgrade -y && \ 
    echo " " && \
    echo "Auto removing apt packages..." && \
    echo " " && \
    sudo apt autoremove -y && \
    echo " " && \
    echo "Auto cleaning  apt packages..." && \
    echo " " && \
    sudo apt autoclean -y && \
    echo " " && \
    echo "Upgrading flatpack packages..." && \
    echo " " && \
    flatpak update -y
