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

typedef bit<48> mac_addr_t;
typedef bit<16> ether_type_t;

header ethernet_t {
    mac_addr_t dst_addr;
    mac_addr_t src_addr;
    bit<16> ether_type;
}

header rule_1 {
    bit<624> pad1;  // 78 bytes
    bit<32> vul1;   // 4 bytes
    bit<8> pad2;    // 1 byte
    bit<24> vul2;   // 3 bytes
    bit<8> pad3;    // 1 byte
    bit<24> vul3;   // 3 bytes 
}

struct header_t {
    ethernet_t       ethernet;
//    rule_1           rule_1;
}


/* Custom metadata to be forwarded */
struct metadata_t {}

#endif /* _HEADERS_ */
