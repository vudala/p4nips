#!/bin/bash

# Check parameters
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

ARCH=tofino2
P4PROG=nips

cd $SDE_INSTALL/bin

# Compile P4 code into binaries
./p4c $P4NIPS/src/$P4PROG.p4 -b $ARCH -o $SDE_INSTALL/share/p4/targets/$ARCH/$P4PROG --std p4-16

# Generate conf files to simulator
./p4c-gen-bfrt-conf --name $P4PROG --device $ARCH --pipe pipe --testdir $SDE_INSTALL/share/p4/targets/$ARCH/$P4PROG --installdir $SDE_INSTALL/share/p4/targets/$ARCH/$P4PROG
mv $SDE_INSTALL/share/p4/targets/$ARCH/$P4PROG/bfrt.json $SDE_INSTALL/share/p4/targets/$ARCH/$P4PROG/bf-rt.json
