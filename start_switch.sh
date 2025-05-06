#!/bin/bash

P4PROG=nips

# 128
sudo ${SDE_INSTALL}/bin/veth_setup.sh 128

############################ Compilation ####################################
source $P4NIPS/p4_build.sh

tmux set-option history-limit 500000

############################ Simulation ####################################
tmux new-session -d -s switch -n simulation

tmux split-window -t 0 -h
tmux split-window -t 1 -v

tmux send-keys -t 1 "cd $SDE" C-m
tmux send-keys -t 1 "./run_switchd.sh --arch tf2 -p $P4PROG" C-m

mkdir -p $SDE/logs

tmux send-keys -t 2 "cd $SDE" C-m
tmux send-keys -t 2 "./run_tofino_model.sh --arch tf2 --log-dir $SDE/logs -c $SDE_INSTALL/share/p4/targets/tofino2/$P4PROG/bfrt.json -p $P4PROG" C-m


tmux attach-session -t switch 
