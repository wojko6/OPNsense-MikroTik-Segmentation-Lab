# Network Architecture

## Overview

This lab implements a segmented network environment in **GNS3**, using **OPNsense** as the perimeter firewall and **MikroTik RouterOS CHR** as an internal router.

The architecture separates three security zones:

- trusted management LAN
- laboratory / transit network
- downstream MikroTik client network

OPNsense acts as the primary security enforcement point between network segments, while MikroTik provides routing and DHCP services for the downstream client network.

## Logical Topology

```text
                         Internet
                            |
                         GNS3 NAT
                            |
                      OPNsense WAN
                     192.168.122.x
                            |
                     +-------------+
                     |   OPNsense  |
                     +-------------+
                       |         |
          LAN 192.168.1.1       OPT1 192.168.20.1
                       |         |
                    Switch1    Switch2
                     /  \       / | \
                    /    \     /  |  \
                  PC1   Fedora PC2 LAB-SRV
                               |
                         MikroTik CHR
                      ether1 192.168.20.2
                               |
                      ether2 192.168.30.1
                               |
                            Switch3
                               |
                              PC3
                               |
                       192.168.30.0/24
```

## Network Segments

### WAN — `192.168.122.0/24`

Provides upstream connectivity to OPNsense through the GNS3 NAT node.

### Trusted LAN — `192.168.1.0/24`

Primary trusted and management network.

- OPNsense LAN: `192.168.1.1/24`
- Fedora management host: `192.168.1.10`
- PC1: trusted LAN test client

### LAB / Transit — `192.168.20.0/24`

Connects OPNsense OPT1, laboratory systems and the MikroTik CHR uplink.

- OPNsense OPT1: `192.168.20.1/24`
- MikroTik `ether1`: `192.168.20.2/24`
- PC2: LAB test client
- LAB-SRV: laboratory server

### MikroTik LAN — `192.168.30.0/24`

Downstream client network routed by MikroTik CHR.

- MikroTik `ether2`: `192.168.30.1/24`
- DHCP pool: `192.168.30.100-192.168.30.199`
- PC3: downstream validation client

## Routing

MikroTik uses OPNsense as its upstream router:

```text
0.0.0.0/0 → 192.168.20.1
```

OPNsense contains a return route for the downstream MikroTik network:

```text
192.168.30.0/24 → 192.168.20.2
```

This provides bidirectional routing between OPNsense and the MikroTik downstream network.

Outbound traffic from `192.168.30.0/24` is translated on the OPNsense WAN interface before reaching the Internet.

## Security Boundaries

The primary security policy is:

```text
MikroTik LAN → Internet      ALLOW
MikroTik LAN → Trusted LAN   BLOCK
```

Traffic originating from `192.168.30.0/24` can therefore reach the Internet while being explicitly prevented from initiating connections to the trusted `192.168.1.0/24` network.

OPNsense performs inter-segment firewall enforcement and logs the resulting allow/block decisions.

## MikroTik Management Hardening

MikroTik CHR additionally protects its management plane through:

- default-deny INPUT policy
- established/related connection handling
- invalid-state dropping
- SSH restricted to `192.168.1.10/32`
- WinBox restricted to `192.168.1.10/32`
- unnecessary RouterOS management services disabled

The FORWARD chain retains the rules required for downstream routing, while inter-segment access policy is enforced by OPNsense.

## Traffic Flows

### Allowed

```text
PC3
 ↓
MikroTik
 ↓
OPNsense
 ↓
Internet
```

Management access:

```text
Fedora
 ↓
OPNsense
 ↓
MikroTik SSH / WinBox
```

### Blocked

```text
PC3
 ↓
MikroTik
 ↓
OPNsense
 X
Trusted LAN
```

The blocked traffic is recorded by OPNsense, demonstrating that segmentation is enforced by an explicit firewall policy rather than by missing routes.

## Design Summary

The architecture separates routing responsibilities from security-policy enforcement:

- **MikroTik CHR** provides routing and DHCP for the downstream `192.168.30.0/24` network.
- **OPNsense** provides inter-segment firewalling, logging, upstream routing and WAN NAT.
- **Fedora** acts as the designated management workstation.
- **PC1, PC2 and PC3** provide controlled validation endpoints.
- **LAB-SRV** represents a service hosted inside the laboratory segment.

This design allows routing functionality, firewall segmentation and management-plane hardening to be validated independently.
