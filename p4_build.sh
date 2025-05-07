#!/bin/bash

if [ -z ${SDE+x} ]; then
    echo "SDE is unset";
    echo "set: $SDE=~/bf-sde-x.y.z/";
    exit 1
else
    echo "SDE is set to '$SDE'";
fi

if [ -z ${SDE_INSTALL+x} ]; then
    echo "SDE_INSTALL is unset";
    echo "set: $SDE_INSTALL=$SDE/install'";
    exit 1
else
    echo "SDE_INSTALL is set to '$SDE_INSTALL'";
fi

cd $SDE_INSTALL/bin
./p4c --verbose 2 -I. $P4NIPS/src/nips.p4 -b tofino2 -o $SDE_INSTALL/share/p4/targets/tofino2/nips
