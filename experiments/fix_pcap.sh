#!/bin/bash

in_pcap="$1"

#echo $in_pcap
#apt install tshark tcpreplay
editcap -r $in_pcap input.pcap 1-5000  						# pega os 5000 primeiros pacotes do pcap recebido como parâmetro e joga em "input.pcap"
tcprewrite --mtu=1500 --mtu-trunc --infile=input.pcap --outfile=output.pcap  	# trunca os pacotes do pacp recém criado para MTU=1500 bytes e joga em "output.pcap"
rm input.pcap
