#ifndef _HEADERS_
    #define _HEADERS_

#include <core.p4>
#include <v1model.p4>

#if __TARGET_TOFINO__ == 3
#include <t3na.p4>
#elif __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

header ethernet_t {
    bit<48> dst_addr;
    bit<48> src_addr;
    bit<16> ether_type;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> total_len;
    bit<16> identification;
    bit<3>  flags;
    bit<13> frag_offset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdr_checksum;
    bit<32> src_addr;
    bit<32> dst_addr;
}

/*
TCP based on RFC 9293
https://datatracker.ietf.org/doc/html/rfc9293
*/
header tcp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> seq_no;
    bit<32> ack_no;
    bit<4>  data_offset;
    bit<4>  res;
    bit<8>  ctrl;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgent_ptr;
}

/*
[TCP Option]; size(Options) == (data_offset-5)*32; present only when DOffset > 5
*/
header tcp_options_t {
    varbit<352> opts;
}

header signature_t {
    bit<624> pad1;  // 78 bytes
    bit<32> vul1;   // 4 bytes (text)
    bit<8> pad2;    // 1 byte
    bit<24> vul2;   // 3 bytes (0x000000)
    bit<8> pad3;    // 1 byte    
    bit<24> vul3;   // 3 bytes (0x45256D)
}

struct header_t {
    ethernet_t       ethernet;
    ipv4_t           ipv4;
    tcp_t            tcp;
    tcp_options_t    tcp_options;
    signature_t      signature;
}

struct metadata_t {}



#endif /* _HEADERS_ */
