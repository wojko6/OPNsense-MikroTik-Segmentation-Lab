# Validation and Security Testing

## Test 1 - OPNsense ICMP policy enforcement

**Result: PASS**

An explicit ICMP block rule was tested on the OPNsense LAN interface.

After placing the block rule above the general allow rule:
- PC1 -> 192.168.1.1 was blocked
- PC1 -> 1.1.1.1 was blocked
- OPNsense Live View confirmed the blocked traffic

The test rule was then disabled and connectivity was restored.

## Test 2 - LAB Internet connectivity

**Result: PASS**

PC2 in the 192.168.20.0/24 network successfully reached 1.1.1.1 through OPNsense.

## Test 3 - MikroTik DHCP

**Result: PASS**

PC3 received:
- IP: 192.168.30.199/24
- Gateway: 192.168.30.1
- DNS: 1.1.1.1

DHCP pool:
192.168.30.100-192.168.30.199

## Test 4 - MikroTik gateway connectivity

**Result: PASS**

PC3 successfully reached its MikroTik gateway at 192.168.30.1.

## Test 5 - MikroTik LAN Internet access

**Result: PASS**

PC3 successfully reached 1.1.1.1 through MikroTik CHR and OPNsense.

## Test 6 - MikroTik LAN isolation

**Result: PASS**

Traffic from 192.168.30.0/24 to the trusted 192.168.1.0/24 LAN was blocked.

Test:
PC3 -> 192.168.1.1 = BLOCK

OPNsense Live View confirmed:
- Interface: OPT1
- Protocol: ICMP
- Source: 192.168.30.199
- Destination: 192.168.1.1
- Action: block
- Rule: MIKROTIK-LAN - Block access to LAN

## Test 7 - MikroTik management hardening

**Result: PASS**

Unnecessary RouterOS services were disabled.

SSH and WinBox were retained and restricted to the Fedora management host:

192.168.1.10/32

## Test 8 - RouterOS INPUT firewall

**Result: PASS**

Implemented:
- accept established/related INPUT
- drop invalid INPUT
- allow management from 192.168.1.10
- drop all remaining INPUT traffic
- established/related handling in FORWARD
- invalid-state dropping in FORWARD

## Test 9 - Post-hardening regression

**Result: PASS**

After MikroTik hardening:

PC3 -> 1.1.1.1 = PASS
PC3 -> 192.168.1.1 = BLOCK
Fedora -> MikroTik SSH = PASS

A new SSH session was successfully established after the INPUT firewall policy was enabled.

## Final result

**Overall validation status: PASS**
