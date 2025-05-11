#!/bin/bash

ARCH=tofino2
P4PROG=nips

$P4NIPS/kill_switch.sh

# 128
sudo ${SDE_INSTALL}/bin/veth_setup.sh 128

tmux set-option history-limit 500000

tmux new-session -d -s switch -n simulation

tmux split-window -t 0 -h
tmux split-window -t 1 -v

tmux send-keys -t 1 "cd $SDE" C-m
tmux send-keys -t 1 "./run_switchd.sh --arch $ARCH -c $SDE_INSTALL/share/p4/targets/$ARCH/$P4PROG/$P4PROG.conf -p $P4PROG" C-m

mkdir -p $SDE/logs

tmux send-keys -t 2 "cd $SDE" C-m
tmux send-keys -t 2 "./run_tofino_model.sh --arch $ARCH --log-dir $SDE/logs \
    -c $SDE_INSTALL/share/p4/targets/$ARCH/$P4PROG/$P4PROG.conf \
    -f $P4NIPS/ports.json -p $P4PROG" C-m

tmux send-keys -t 0 "cd $SDE" C-m
tmux send-keys -t 0 "./run_bfshell.sh -b $P4NIPS/src/setup.py" C-m

tmux attach-session -t switch
