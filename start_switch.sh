#!/bin/bash

if [ -z $1 ]; then
    echo "P4_PROG is missing";
    echo "Usage: ./start_switch.sh PROGRAM_NAME";
    exit 1
fi

P4_PROG=$1
P4_PATH="~/src"

sudo $SDE/install/bin/veth_setup.sh

############################ Compilation ####################################
pushd ~/src
../p4_build.sh $P4_PROG
popd

tmux set-option history-limit 500000

############################ Simulation ####################################
tmux new-session -d -s switch -n simulation

tmux split-window -t 0 -h
tmux split-window -t 1 -v

tmux send-keys -t 1 "cd $SDE" C-m
tmux send-keys -t 1 "./run_switchd.sh -p $P4_PROG -c $SDE_INSTALL/share/p4/targets/tofino2/$P4_PROG/$P4_PROG.conf --arch tf2" C-m

mkdir -p $SDE_INSTALL/../logs

tmux send-keys -t 2 "cd $SDE" C-m
tmux send-keys -t 2 "./run_tofino_model.sh -p $P4_PROG -c $SDE_INSTALL/share/p4/targets/tofino2/$P4_PROG/$P4_PROG.conf --arch tf2 -f $P4JOIN_SRC/p4src/ports.json --log-dir $SDE_INSTALL/../logs" C-m

tmux send-keys -t 0 "cd $SDE" C-m
tmux send-keys -t 0 "./run_bfshell.sh -b $P4_PATH/$P4_PROG/bfrt_python/setup.py" C-m

tmux attach-session -t switch 
