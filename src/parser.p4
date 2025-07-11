#ifndef _PARSER_
    #define _PARSER_

/* ===================================================== Tofino Parsers ===================================================== */
/*  These are intrisic Tofino parsers for intrisic Tofino headers, not to be changed */

parser TofinoIngressParser(
        packet_in pkt,
        out ingress_intrinsic_metadata_t ig_intr_md)
{
    state start {
        pkt.extract(ig_intr_md);
        transition select(ig_intr_md.resubmit_flag) {
            1 : parse_resubmit;
            0 : parse_port_metadata;
        }
    }

    state parse_resubmit {
        transition reject;
    }

    state parse_port_metadata {
        pkt.advance(PORT_METADATA_SIZE);
        transition accept;
    }
}

parser TofinoEgressParser(
        packet_in pkt,
        out egress_intrinsic_metadata_t eg_intr_md)
{
    state start {
        pkt.extract(eg_intr_md);
        transition accept;
    }
}

/* ===================================================== Ingress ===================================================== */

// ---------------------------------------------------------------------------
// Ingress Parser
// ---------------------------------------------------------------------------

parser SwitchIngressParser(
    packet_in packet,
    /* User */
    out header_t        hdr,
    out metadata_t      meta,
    /* Intrinsic */
    out ingress_intrinsic_metadata_t ig_intr_md)
{
    const bit<16> ETHERTYPE_IPV4 = 0x0800;
    const bit<8> IPV4_PROTOCOL_TCP = 6;

    TofinoIngressParser() tofino_parser;

    /* Parser starting point */
    state start {
        // Parse Tofino intrinsic headers
        tofino_parser.apply(packet, ig_intr_md);
        transition parse_ethernet;
    }

    /* Parser ethernet headers */
    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    /* Parse IPV4 headers */
    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.frag_offset,
                          hdr.ipv4.protocol,
                          hdr.ipv4.ihl) {
            (0, IPV4_PROTOCOL_TCP, 5): parse_tcp;
            (0, _, _): parse_ipv4_options;
            default: accept;
        }
    }

    /* If theres IPV4 optios, parse it */
    state parse_ipv4_options {
        /* Calculate how many bytes to be extracted and extract */
        packet.extract(hdr.ipv4_options, ((bit<32>) (hdr.ipv4.ihl - 5)) * 32);
        transition select(hdr.ipv4.protocol) {
            IPV4_PROTOCOL_TCP: parse_tcp;
            default: accept;
        }
    }

    /* Parse TCP if ipv4.protocol = 6 */
    state parse_tcp {
        packet.extract(hdr.tcp);
        transition select(hdr.tcp.data_offset) {
            5: parse_signature;
            // If data_offset greater than 5, parse TCP options
            _: parse_tcp_options;
        }
    }

    // Parse TCP options if theres any
    state parse_tcp_options {
        packet.extract(hdr.tcp_options, ((bit<32>) (hdr.tcp.data_offset - 5)) * 32);
        transition parse_signature;
    }

    // Finally, extract the data from the payload as headers, to be compared
    state parse_signature {
        packet.extract(hdr.signature);
        transition accept;
    }
}

// ---------------------------------------------------------------------------
// Ingress Deparser
// ---------------------------------------------------------------------------
control SwitchIngressDeparser(packet_out pkt,
    /* User */
    inout header_t      hdr,
    in metadata_t       meta,
    /* Intrinsic */
    in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md)
{
    apply {
        // Reemit parsed data
        pkt.emit(hdr);
    }
}

/* ===================================================== Egress ===================================================== */

// ---------------------------------------------------------------------------
// Egress Parser
// ---------------------------------------------------------------------------
parser SwitchEgressParser(packet_in pkt,
    /* User */
    out header_t        hdr,
    out metadata_t      meta,
    /* Intrinsic */
    out egress_intrinsic_metadata_t eg_intr_md)
{
    TofinoEgressParser() tofino_parser;

    /* Parse starting point */
    state start {
        tofino_parser.apply(pkt, eg_intr_md);
        transition accept;
    }
}

// ---------------------------------------------------------------------------
// Egress Deparser
// ---------------------------------------------------------------------------
control SwitchEgressDeparser(packet_out pkt,
    /* User */
    inout header_t      hdr,
    in metadata_t       meta,
    /* Intrinsic */
    in egress_intrinsic_metadata_for_deparser_t eg_dprsr_md)
{
    apply {}
}


#endif /* _PARSER_ */
