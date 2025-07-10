from scapy.all import *
from scapy.layers.l2 import Ether
import threading 
import time

# Inteface linked to port 10 of the switch
interface = 'veth21'

count = 0

# Define a callback function to process each sniffed packet
def process_packet(pkt):
    global count
    count += 1

# Counts packets processed in the last second
def monitor():
    last_count = 0
    tstamp = 0
    while True:
        print(f"{tstamp} RX: {count - last_count}")
        tstamp += 1
        last_count = count
        time.sleep(1)

threads = []

# Create a thread to count the packets
t1 = threading.Thread(target=monitor)
threads.append(t1)

# Create a thread to sniff the packets
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
