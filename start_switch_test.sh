#!/bin/bash

P4TEST=tna_counter

# 128
sudo ${SDE_INSTALL}/bin/veth_setup.sh 32

tmux set-option history-limit 500000

############################ Simulation ####################################
tmux new-session -d -s switch -n simulation

tmux split-window -t 0 -v
tmux split-window -t 0 -h

tmux send-keys -t 0 "cd $SDE" C-m
tmux send-keys -t 0 "./run_tofino_model.sh -p $P4TEST --arch tofino2" C-m

mkdir -p $SDE/logs

tmux send-keys -t 1 "cd $SDE" C-m
tmux send-keys -t 1 "./run_switchd.sh -p $P4TEST --arch tofino2 --log-dir $SDE/logs" C-m

tmux send-keys -t 2 "cd $SDE" C-m
tmux send-keys -t 2 "./run_p4_tests.sh -p $P4TEST --arch ofino2" C-m

tmux attach-session -t switch 
