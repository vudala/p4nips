from scapy.all import *
from scapy.layers.l2 import Ether

ETHER_TEST = 0x8234
class Test(Packet):
    name = 'Test'
    fields_desc = [
        IntField('index', -1)
    ]

bind_layers(Ether, Test, type=ETHER_TEST)

for i in range(64):
    if i >= 16:
        ethf = Ether(dst="00:00:00:00:00:03")
        tst = Test(index = i)
        sendp(ethf / tst, iface = f'veth{i}')
        print(f"Sent on iface veth{i}")
