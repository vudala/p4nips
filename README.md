# P4 NIPS
Implementing a Network Intrusion Protection System in a P4 switch


# Why would be advantageous to have a NIPS in the switch?

## Pros
- Offloading the computation from a IDS
- Programmable ASIC switches (Tofino, Tomahawk, Trident, Teralynx, etc) are
fast as fuck to process a packet (some tens of cycles at most), compared to
a software switch or IDS.
- More

## Cons
- Increased latency
- More

# Reference articles

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
- https://p4.org/wp-content/uploads/2024/10/P4-16-spec-v1.2.5.html


# Tofino simulator

I have compiled and created a Docker image with
[Open P4 Studio](https://github.com/p4lang/open-p4studio) in it.
It simulates a Tofino switch that can be used to homolagate your P4 programs.

The source code of the image is in 
[this repo](https://github.com/vudala/docker-open-p4studio).

## Running 

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

From here you can use the simulator as described in
[Open P4 Studio](https://github.com/p4lang/open-p4studio).


# TODO
1. Create parser for IP -> TCP -> Malicious Signature inside TCP
2. Implement the single rule in rules/snort.rules
3. Expand this README to teach how to run p4-nips