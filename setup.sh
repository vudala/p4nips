#!/bin/bash

pip install -r requirements.txt

sudo apt update -y

sudo apt-get install -y \
    tcpreplay \
    tmux \
    python3-scapy \
    tshark

echo export P4NIPS=$(pwd) >> ~/.bashrc

source ~/.bashrc
