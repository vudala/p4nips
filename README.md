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

# TODO
1. Create parser for IP -> TCP -> HTTP
2. Implement the single rule in rules/snort.rules


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
