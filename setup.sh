#!/bin/bash

# Install python dependencies
pip install -r requirements.txt

# Install tools
sudo apt update -y

sudo apt-get install -y \
    tcpreplay \
    tmux \
    python3-scapy \
    tshark

# Sets up env variables
echo export P4NIPS=$(pwd) >> ~/.bashrc

source ~/.bashrc
