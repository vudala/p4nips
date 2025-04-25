#!/bin/bash

pip install -r requirements.txt

sudo apt-get install -y \
    tcpreplay \
    tmux

echo export P4SRC=$(pwd) >> ~/.bashrc

source ~/.bashrc
