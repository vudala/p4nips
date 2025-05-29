from scapy.all import *
from scapy.layers.l2 import Ether
import threading 
import time

interface = 'veth21'

count = 0

# Define a callback function to process each sniffed packet
def process_packet(pkt):
    global count
    count += 1

def monitor():
    last_count = 0
    while True:
        print(f"RX: {count - last_count}")
        last_count = count
        time.sleep(1)

threads = []

t1 = threading.Thread(target=monitor)
threads.append(t1)
t2 = threading.Thread(
    target=sniff,
    kwargs={"prn": process_packet, "iface": interface}
)
threads.append(t2)

# Start each thread
for t in threads:
    t.start()

# Wait for all threads to finish
for t in threads:
    t.join()
