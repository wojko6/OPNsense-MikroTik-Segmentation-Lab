# Network Architecture

## Overview

This lab implements a segmented network environment in GNS3 using OPNsense as the perimeter firewall and MikroTik RouterOS CHR as an internal router.

The design separates trusted management systems, a laboratory/transit network and a downstream MikroTik client network.

## Logical topology

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
                  |           |
          LAN 192.168.1.1   OPT1 192.168.20.1
                  |           |
               Switch1     Switch2
                /             | \
               /              |  \
            PC1           LAB-SRV  PC2
             |                 |
     Management LAN       192.168.20.0/24
     192.168.1.0/24            |
                               |
                         MikroTik CHR
                         ether1 .20.2
                               |
                         ether2 .30.1
                               |
                            Switch3
                               |
                              PC3

                        192.168.30.0/24
```


## Network segments

### WAN — 192.168.122.0/24

Provides upstream Internet connectivity to OPNsense through the GNS3 NAT node.

### Trusted LAN — 192.168.1.0/24

Primary management network.

OPNsense:

192.168.1.1/24

Fedora management host:

192.168.1.10/32
### LAB / Transit — 192.168.20.0/24

Connects OPNsense OPT1, laboratory systems and the MikroTik CHR uplink.

OPNsense:

192.168.20.1/24

MikroTik CHR ether1:

192.168.20.2/24
### MikroTik LAN — 192.168.30.0/24

Downstream client network routed by MikroTik CHR.

MikroTik CHR ether2:

192.168.30.1/24

DHCP pool:

192.168.30.100-192.168.30.199
## Routing

MikroTik uses OPNsense as its upstream router:
0.0.0.0/0 -> 192.168.20.1
OPNsense contains a route for:
192.168.30.0/24 -> 192.168.20.2
Outbound traffic from the MikroTik LAN is translated on the OPNsense WAN interface.

## Security boundaries

Traffic originating from 192.168.30.0/24 is permitted to reach the Internet but is explicitly prevented from initiating connections to the trusted 192.168.1.0/24 LAN.

OPNsense performs inter-segment policy enforcement and logging.

MikroTik CHR additionally protects its own management plane with:

default-deny INPUT policy
established/related state handling
invalid-state dropping
SSH/WinBox restricted to 192.168.1.10/32
unnecessary RouterOS management services disabled
## Traffic examples

### Allowed
PC3 -> MikroTik -> OPNsense -> Internet
Fedora management host -> OPNsense -> MikroTik SSH
### Blocked
PC3 -> MikroTik -> OPNsense -X-> Trusted LAN
The blocked traffic is logged by OPNsense, providing evidence that segmentation is enforced by policy rather than by lack of routing.
