# P4NIPS: P4 Network Intrusion Prevention System

**Abstract**: An IPS must be deployed in line with the network traffic to be able to
drop or accept packets according to evaluations done. Due to this, traditional
IPS usage typically has an adverse effect on the network’s latency and
throughput. To mitigate the efficiency problem, we propose P4NIPS, an IPS built
with P4 intended to run on a programmable switch. Its viability is demonstrated
in a simulated environment, where the architecture of the Tofino 2 chip is used.

This repository contains the P4 code of P4NIPS. Furthermore it also has scripts
and data to replicate the tests described in the paper.

Video with tool demo:
https://www.youtube.com/watch?v=ezTnBPJ5JUw&t=27s&ab_channel=SubmissionSbseg

# README.md structure

Thise README.md is organized in the following sections:

- Title and Abstract: Project title and abstract (copied from the paper).
- README.md structure: Describes the repository functionality and structure.
- Considered stamps: Stamps to be considered on evaluation.
- Basic information: Describes the minimum setup to run P4NIPS.
- Dependencies: Lists the software requirements.
- Security precautions: Cautions that the user must take before using the tool.
- Installation: Steps to install and configure P4NIPS.
- Minimum test: Describes steps to test the minimum functionalities of the tool.
- Experiments: Steps on how to reproduce the experiments of the paper.
- LICENSE: Legal disclaimers.


## File structure

Directory tree of the files in the repository.

```console
p4nips
├── docker-compose.yml  # Docker compose config file to run Open P4 Studio
├── experiments
│   ├── benign.pcap     # PCAP with benign data
│   ├── malicious.pcap  # PCAP with malicious data
│   ├── mal_pcap_gen.py # Python script to generate 5000 malicious packets 
│   └── trim_pcap.sh    # Python script to extracts the first 5000 packets from a PCAP
├── kill_switch.sh      # Bash script to kill the tmux session that runs the switch
├── p4_build.sh         # Bash script to compile the P4 code
├── ports.json          # JSON file that describes the port mapping to virtual ethernet interfaces
├── README.md           # Description of this repository
├── requirements.txt    # Python script dependencies
├── rules
│   └── snort.rules     # Contains the reference rule of the article
├── setup.sh            # Bash script to install dependencies of the project
├── src
│   ├── headers.p4      # P4 code that contains the headers
│   ├── nips.p4         # Main P4 code of P4NIPS, imports parser.p4 and headers.p4
│   ├── parser.p4       # P4 code that contains the parsers and deparsers
│   └── setup.py        # Python code that interacts with Barefoot Runtime control plane to update the tables
├── start_switch.sh     # Bash script to start the switch simulation within a tmux
└── tools
    ├── monitor.py      # Python script to monitor veth21 interface and count the packets
    └── sniff.py        # Python script to test if P4NIPS is working properly
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
The tool works with Docker and Docker Compose on versions specified further,
although its highly likely that P4NIPS would also run with any other recent
stable version of these softwares.

## Requirements

- OS: Ubuntu 22.04
- 16GB RAM
- 6 CPU cores
- 256GB disk space

# Dependencies

## Software requirements

The experiments were executed using these softwares:

- Git 2.34.1
- Docker Engine 28.2.2
- Docker Compose version v2.36.2

# Security precautions

No risks attached to this work.

# Installation

## Running the container
There is a `docker-compose.yml` in this repo that runs the container
described in the paper.

Using a terminal, clone the repository:
```bash
git clone git@github.com:vudala/p4nips.git
```

Then run the container:
```bash
cd p4nips
docker compose up -d
```
This step takes some mintutes the first time is executed, since it downloads the
image that has the P4 studio installed in it.
If your disk or internet bandwidth is not so fast this will take a long time.
Be patient.


Once its done, access the container executing:
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

To check that everything was setup successfully run:
```bash
echo $P4NIPS
```
This should be printed as result:
```console
/home/dev/p4nips
```

### Compile
Once all dependencies are installed, compile P4NIPS code into the Tofino binary
and config files:
```bash
cd ~/p4nips
./p4_build.sh
```

## General observations and possible problems

If any of these steps fail for some reason, follow these steps to troubleshoot
it.

- **Failure on cloning the repository**: be sure to have an SSH key setup
correctly for your GitHub account, or clone using HTTPS. You could also be
having connection issues, so check your internet connection. 
- **Failure while pulling Docker image**: you are probably having connection
issues, check your internet connection.
- **Failure while executing Docker Compose**: the container is not starting
successfully, check if you have enough disk/memory and permissions.
root permission necessary. The Docker service uses port 2222 for ssh
connections, certify that you dont have any other service running on port 2222 
on host machine.
- **Failure while running `setup.sh`**: you could also be out of connectivity,
check you internet connection. Be aware that it will ask for user prompt while
installing tshark, input 'yes' or 'no'.
- **Failure while compiling P4NIPS**: this should not happen at all, reset
everything and start from scratch. 

## Reseting installation

To clean up installation and start again, leave the container using `CTRL + D`,
and run `docker compose down` on the root of the repository to kill the container.
You could also delete the repository and clone it again.

# Test run

This section describes the steps to check if the previous steps succeeded.
We are going to send some packets through P4NIPS and see if they flow correctly.

All of the commands will be issued through tmux sessions for organization.

## Start the switch
Start the switch:
```bash
cd ~/p4nips
./start_switch.sh
```
This will open a tmux session with three panes: the pane down-right is running
Tofino chip simulation (A), the pane up-right is running Barefoot Runtime
control plane (B) and the plane to the left runs a script that configures the
routing tables of P4NIPS (C).

Once pane C displays a message like: "bfshell> exit", the switch will be ready
to route packets.

Then `CTRL + B + D` to detach from tmux session. You could go back to this
session using `tmux attach -t switch` but wont be necessary for the following 
steps.

## Sending traffic through P4NIPS

To ease troubleshooting, all of the traffic that P4NIPS controls
is forwarded to port 10.

Port 10 is mapped to interface 'veth21'
So every packet that you send to the switch, will be either dropped or can be
sniffed in interface 'veth21'.

We are going to send some packages to P4NIPS, and sniff the output port to test
if its working properly.

Create a new tmux session:
```bash
tmux
```
Then split it in two panes pressing `CTRL + B + %`. To switch between panes press
`CTRL + B + Left` or `CTRL + B + Right`.

In the right pane, start sniffing for packets on interface 'veth21', using:
```bash
cd ~/p4nips/tools
sudo python3 sniff.py
```

In the left pane, start sending traffic to P4NIPS running the command:
```bash
cd ~/p4nips/experiments
sudo tcpreplay -i veth17 --pps 25 benign.pcap
```

In the right pane you should start seeing a lot of data being printed in the
console. These are the packet contents of that pcap in hex or ASCII.
This means that P4NIPS is working correctly.

Kill the tmux session to proceed to the experimentation.
Press `CTRL + B + :`, then type `kill-session` and press `Enter`.

# Experiments

P4NIPS is created as proof-of-concept that blocks malicious data at transmission
time. Here are the demonstration of its functionalities.

Create a new tmux session to run the experiments:
```bash
tmux
```
Then split it in two panes pressing `CTRL + B + %`. To switch between panes press
`CTRL + B + Left` or `CTRL + B + Right`.

## Routes packets normally
In the right pane, start count the packet that are redirected to port 10, using:
```bash
cd ~/p4nips/tools
sudo python3 monitor.py
```
The received packets quantity received in the last second will start being 
printed in a timeseries:

```console
0 RX: 0
1 RX: 0
2 RX: 0
...
```

In the left pane, start sending web traffic to P4NIPS running the command:
```bash
cd ~/p4nips/experiments
sudo tcpreplay -i veth17 --pps 25 benign.pcap
```

Result in the right pane:
```console
7 RX: 0
8 RX: 19
9 RX: 25
10 RX: 25
11 RX: 25
...
```

## Blocks malicious traffic

Now, we are going to send malicious traffic to P4NIPS, and verify its dropped.

In the left pane cancel the running process, and start sending web traffic to
P4NIPS using the same command as before, but with a different pcap:
```bash
cd ~/p4nips/experiments
sudo tcpreplay -i veth17 --pps 25 malicious.pcap
```

Result in the right pane:
```console
39 RX: 0
40 RX: 0
41 RX: 0
42 RX: 0
43 RX: 0
...
```

# LICENSE

Apresente a licença.

