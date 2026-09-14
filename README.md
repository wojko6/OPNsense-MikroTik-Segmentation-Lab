# OPNsense & MikroTik Network Segmentation Lab

Practical network-security lab built in GNS3 using OPNsense and MikroTik RouterOS CHR.

## Architecture

The environment demonstrates multi-segment routing, firewall policy enforcement, NAT, DHCP, administrative access control and security hardening.

### Networks

| Segment | Network | Gateway / Device | Purpose |
|---|---|---|---|
| WAN | 192.168.122.0/24 | OPNsense WAN | Internet/NAT uplink |
| LAN | 192.168.1.0/24 | OPNsense 192.168.1.1 | Management / trusted LAN |
| LAB | 192.168.20.0/24 | OPNsense 192.168.20.1 | Lab / transit segment |
| MikroTik LAN | 192.168.30.0/24 | MikroTik 192.168.30.1 | Routed client network |

### Routing

MikroTik CHR:
- ether1: 192.168.20.2/24
- ether2: 192.168.30.1/24
- default gateway: 192.168.20.1

OPNsense provides upstream routing, firewall enforcement and WAN NAT.

## Security controls

- Network segmentation between trusted LAN and lab networks
- OPNsense stateful firewall policy enforcement
- Explicit blocking of MikroTik LAN -> trusted LAN
- Internet access for the MikroTik client network
- Logged firewall decisions for verification
- MikroTik default-deny INPUT policy
- Invalid connection-state filtering
- Established/related state handling
- Administrative access restricted to management host 192.168.1.10/32
- Unnecessary RouterOS services disabled
- SSH and WinBox retained for controlled administration

## Validation

The lab was validated with controlled connectivity tests.

- PC3 -> MikroTik gateway: PASS
- PC3 -> Internet (1.1.1.1): PASS
- PC3 -> trusted LAN (192.168.1.1): BLOCKED as designed
- Fedora management host -> MikroTik SSH: PASS
- OPNsense firewall logs confirmed policy enforcement
- Connectivity remained operational after MikroTik hardening

## Repository structure

- `configs/` - sanitized device configuration exports
- `docs/` - architecture and implementation documentation
- `evidence/` - validation and firewall evidence

## Status

OPNsense + MikroTik segmentation and hardening scenario successfully validated in GNS3.

## Evidence

### Final GNS3 topology

![Final GNS3 topology](evidence/topology/01-final-gns3-topology.png)

### OPNsense firewall segmentation

![OPNsense firewall Live View](evidence/opnsense/02-segmentation-firewall-live-view.png)

### MikroTik DHCP and gateway validation

![PC3 DHCP and gateway](evidence/mikrotik/03-pc3-dhcp-and-gateway.png)

### Internet connectivity from MikroTik LAN

![PC3 Internet access](evidence/mikrotik/04-pc3-internet-pass.png)

### Trusted LAN isolation

![PC3 trusted LAN blocked](evidence/mikrotik/05-pc3-trusted-lan-block.png)

### RouterOS service hardening

![RouterOS service hardening](evidence/mikrotik/06-routeros-service-hardening.png)

### SSH management from Fedora

![Fedora SSH management](evidence/mikrotik/07-fedora-ssh-management.png)
