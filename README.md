# P4NIPS: P4 Network Intrusion Prevention System

An IPS must be deployed in line with the network traffic to be able to
drop or accept packets according to evaluations done. Due to this, traditional
IPS usage typically has an adverse effect on the network’s latency and
throughput. To mitigate the efficiency problem, we propose P4NIPS, an IPS built
with P4 intended to run on a programmable switch. Its viability is demonstrated
in a simulated environment, where the architecture of the Tofino 2 chip is used.

This repository contains the P4 code of P4NIPS. Furthermore it also has scripts
and data to replicate the tests described in the paper.

# Structure

```console
p4nips - Root of the repository
├── docker-compose.yml - Docker compose config file to run Open P4 Studio
├── experiments
│   ├── benign.pcap - PCAP with benign data
│   ├── malicious.pcap - PCAP with malicious data
│   ├── mal_pcap_gen.py - Python script to generate 5000 malicious packets 
│   └── trim_pcap.sh - Python script to extracts the first 5000 packets from a PCAP
├── kill_switch.sh - Bash script to kill the tmux session that runs the switch
├── p4_build.sh - - Bash script to compile the P4 code
├── ports.json - JSON file that describes the port mapping to virtual ethernet interfaces
├── README_final.md
├── README.md
├── requirements.txt - Python script dependencies
├── rules
│   └── snort.rules - Contains the reference rule of the article
├── setup.sh - Bash script to install dependencies of the project
├── src
│   ├── headers.p4 - P4 code that contains the headers
│   ├── nips.p4 - Main P4 code of P4NIPS, imports parser.p4 and headers.p4
│   ├── parser.p4 - P4 code that contains the parsers and deparsers
│   └── setup.py - Python code that interacts with Barefoot Runtime control plane to update the tables
├── start_switch.sh - Bash script to start the switch simulation within a tmux
└── tools
    ├── monitor.py - Python script to monitor the veth21 interface and count the packets
    └── sniff.py - Python script to test if P4NIPS is working properly
```

# Considered stamps

The stamps considered are:
- Artefatos Disponíveis (SeloD)
- Artefatos Funcionais (SeloF)
- Artefatos Sustentáveis (SeloS)
- Experimentos Reprodutíveis (SeloR)

# Basic information

This section specifies the hardware and software setup where the experiments
were executed.
The tool works with any environment that is able to run Docker and Docker Compose
on newer versions.

## Hardware requirements

- 16GB RAM
- 6 CPU cores
- 256GB disk space

# Dependencies

## Software requirements

- OS: Ubuntu 22.04
- Docker Engine 28.2.2
- Docker Compose version v2.36.2

# Security precautions

No risks attached to this work.

# Instalation

## Running the container
There is a `docker-compose.yml` in this repo that runs the image previously
described.

1. Using a terminal, clone the repository
```bash
git clone LINK
```

2. Then run the container
```bash
cd p4nips
docker compose up -d
```
This step takes some mintutes the first time is executed, since it downloads the
image that has the P4 studio installed in it.

3. Access the container
```bash
docker exec -ti p4studio bash
```

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

# Test run

### Start the switch
Then you are ready to start the switch:
```bash
cd ~/p4nips
./start_switch.sh
```

`CTRL + B + D` to detach from tmux session

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

# Experimentos

Esta seção deve descrever um passo a passo para a execução e obtenção dos resultados do artigo. Permitindo que os revisores consigam alcançar as reivindicações apresentadas no artigo.
Cada reivindicações deve ser apresentada em uma subseção, com detalhes de arquivos de configurações a serem alterados, comandos a serem executados, flags a serem utilizadas, tempo esperado de execução, expectativa de recursos a serem utilizados como 1GB RAM/Disk e resultado esperado.

Caso o processo para a reprodução de todos os experimentos não seja possível em tempo viável. Os autores devem escolher as principais reivindicações apresentadas no artigo e apresentar o respectivo processo para reprodução.

## Reivindicações #X

## Reivindicações #Y

# LICENSE

Apresente a licença.

