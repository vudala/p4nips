from scapy.all import *
from scapy.layers.l2 import Ether

interface = 'veth21'

count = 0

ETHER_TEST = 0x8234
class Test(Packet):
    name = 'Test'
    fields_desc = [
        IntField('index', -1)
    ]

bind_layers(Ether, Test, type=ETHER_TEST)

# Define a callback function to process each sniffed packet
def process_packet(pkt):
    pkt.show()

    global count
    count += 1
    print(count)

# Start sniffing packets
print("Sniffing Ethernet frames...")
sniff(prn=process_packet, iface=interface)
