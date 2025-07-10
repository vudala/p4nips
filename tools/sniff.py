from scapy.all import *
from scapy.layers.l2 import Ether

# Inteface linked to port 10 of the switch
interface = 'veth21'

count = 0

# Define a callback function to process each sniffed packet
def process_packet(pkt):
    pkt.show()
    global count
    count += 1
    print(count)

# Start sniffing packets
print("Sniffing Ethernet frames...")
sniff(prn=process_packet, iface=interface)
