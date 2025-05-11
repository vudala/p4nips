#!/bin/bash

pip install -r requirements.txt

sudo apt-get install -y \
    tcpreplay \
    tmux \
    python3-scapy

echo export P4NIPS=$(pwd) >> ~/.bashrc

source ~/.bashrc
