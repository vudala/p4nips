#!/bin/bash

# Check params
in_pcap=$1

if [ -z "$in_pcap" ]; then
    echo No pcap provided
    exit 1
fi

# Fetch big enough packets
tshark -r $in_pcap -Y "tcp and (tcp.len > 224)" -w input.pcap
# Get only 5000 of them
editcap -r $in_pcap input.pcap 1-5000
tcprewrite --mtu=1500 --mtu-trunc --infile=input.pcap --outfile=benign.pcap
rm input.pcap
