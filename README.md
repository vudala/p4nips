# P4 NIPS
Implementing a Network Intrusion Protection System in a P4 switch


# Why would be advantageous to have a NIPS in the switch?

## Pros
- Offloads the computation from a general use machine (packet doesnt need to go
through the TCP/IP stack)
- Programmable ASIC switches (Tofino, Tomahawk, Trident, Teralynx, etc) are
fast as fuck to process a packet (some tens of cycles at most), compared to
a software switch or IDS.
- Has little impact on the latency on the network flow compared to traditional
IPSs
- More

## Cons
- Limited capacities of P4
- Hardware is expensive and unavailable
- More

<!-- # Reference articles

- https://arxiv.org/abs/2411.17987
- https://ieeexplore.ieee.org/document/9040044
- https://cris.unibo.it/retrieve/e1dcb335-4198-7715-e053-1705fe0a6cc9/IEEE_ACCESS_pub.pdf


# P4 study materials

## What is a PISA switch?
Read this to have an overview of what is a programmable switch
- https://sdn.systemsapproach.org/switch.html

## P4 tutorial

Follow this tutorial to understand the basics up to advanced P4 programming
- https://github.com/p4lang/tutorials

## P4 language documentation

Specification of a P4 programmable switch
- https://p4.org/wp-content/uploads/2024/10/P4-16-spec-v1.2.5.html -->

# Running 

This section describes the workflow to run P4NIPS.

First of all, pull the repo:
```bash
git clone git@github.com:vudala/p4nips.git
```

## Open P4 Studio

I have compiled and created a Docker image with
[Open P4 Studio](https://github.com/p4lang/open-p4studio) in it.
Open P4 Studio provides a simulated Tofino chip that can be used to homologate
your P4 programs.

The source code of the image is in 
[this repo](https://github.com/vudala/docker-open-p4studio).

This image is used in this demonstration.

### Dependencies

- Docker Engine (any stable version should do)

## Running the container
There is a `docker-compose.yml` in this repo that runs the image previously
described.

1. Run the container
    ```bash
    cd p4-nips
    docker compose up -d
    ```

2. Access the container
    You can use `docker exec -ti p4studio bash` to do it.
    Or use SSH to access the container:
    ```
    ssh -p 2222 dev@localhost
    ```
    The default password is `p4`.

## Starting P4NIPS

### Setup
When inside the container, install dependencies using:
```bash
cd ~/p4nips
./setup.sh
source ~/.bashrc
```

### Compile
Compile the P4NIPS code into the Tofino binary and config files:
```bash
cd ~/p4nips
./p4_build.sh
```

### Start the switch
Then you are ready to start the switch:
```bash
cd ~/p4nips
./start_switch.sh
```

This script initialized the control plane API (Barefoot Runtime - BFRT), the
Tofino chip simulator, setups virtual ethernet interfaces - which are mapped
against the switch ports - and populates some entries of the control plane using
the client for the BFRT.

## Sending traffic through P4NIPS

This is a test version of the code, so all of the traffic that P4NIPS controls
is forwarded to port 10. That practice is done to ease the troubleshooting of
the tool.

Port 10 is mapped to interface 'veth21'
So every packet that you send to the switch, will be either dropped or can be sniffed
in interface veth21.

### Example

In this example, we send a traffic to an arbitrary port of the switch, and
expect it to be forwarded to port 10. Malicious packets in the traffic
wont arrive at the interface correspondant to port 10, since P4NIPS will drop
them.

#### Monitor the received packets per second (RX) in veth21
```bash
cd ~/p4nips/tools
sudo python3 monitor.py
```
#### Send traffic through any port i.e. port 8, which is mapped to veth17
```bash
sudo tcpreplay -i veth 17 --pps 25 traffic.pcap
```

# TODO
1. ~~Create parser for IP -> TCP -> Malicious signature inside TCP~~
2. ~~Implement the single rule in rules/snort.rules~~
3. ~~Expand this README to teach how to run p4-nips~~
4. ~~Run pcap with tcpreplay to mimic real traffic~~
5. ~~Insert malicious packet in the traffic to determine if IPS is dropping~~
6. Add check to prevent packets too small from being parsed

## Optional
1. Add MAU to check for $EXTERNAL_NET
2. Add MAU to check for $HOME_NET
