#include <core.p4>
#if __TARGET_TOFINO__ == 3
#include <t3na.p4>
#elif __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "parser.p4"


/* ===================================================== Ingress ===================================================== */


control SwitchIngress(
    /* User */
    inout header_t      hdr,
    inout metadata_t    meta,
    /* Intrinsic */
    in ingress_intrinsic_metadata_t                     ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t         ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t     ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t           ig_tm_md)
{
    /* Forward */
    action hit(PortId_t port) {
        ig_tm_md.ucast_egress_port = port;
    }

    action miss(bit<3> drop) {
        ig_dprsr_md.drop_ctl = drop; // drop packet.
    }

    // table forward {
    //     key = {
    //         hdr.ethernet.dst_addr : exact;
    //     }

    //     actions = {
    //         hit;
    //         @defaultonly miss;
    //     }

    //     const default_action = miss(0x1);
    //     size = 1024;
    // }

    action noop(){}

    table http_ports {
        key = {
            hdr.tcp.dst_port : exact;
        }
        actions = {
            noop;
        }
        /*
        Commonly used HTTP ports
        */
        entries = {
            80:   noop;
            8000: noop;
            8008: noop;
            8088: noop;
            8888: noop;
            9000: noop;
        }
        size = 128;
    }

    apply {
        // forward.apply();

        ig_tm_md.ucast_egress_port = 10;

        if (hdr.tcp.isValid()) {
            if (http_ports.apply().hit) {
                if (hdr.signature.isValid()) {
                    if (hdr.signature.vul1 == 0x74657874) // text
                    if (hdr.signature.vul2 == 0x000000)
                    if (hdr.signature.vul3 == 0x45256D)
                        ig_dprsr_md.drop_ctl = 1;
                }
            }
        }
    }
}

/* ===================================================== Egress ===================================================== */

control SwitchEgress(
    /* User */
    inout header_t      hdr,
    inout metadata_t    meta,
    /* Intrinsic */
    in egress_intrinsic_metadata_t                      eg_intr_md,
    in egress_intrinsic_metadata_from_parser_t          eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t      eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t   eg_oport_md)
{
    apply {}
}


/* ===================================================== Final Pipeline ===================================================== */
Pipeline(
    SwitchIngressParser(),
    SwitchIngress(),
    SwitchIngressDeparser(),
    SwitchEgressParser(),
    SwitchEgress(),
    SwitchEgressDeparser()
) pipe;

Switch(pipe) main;
