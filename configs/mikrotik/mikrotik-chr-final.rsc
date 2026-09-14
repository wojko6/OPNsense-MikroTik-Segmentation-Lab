# 2026-09-14 17:25:52 by RouterOS 7.22.1
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
set [ find default-name=ether6 ] disable-running-check=no
set [ find default-name=ether7 ] disable-running-check=no
set [ find default-name=ether8 ] disable-running-check=no
/ip pool
add name=dhcp_pool0 ranges=192.168.30.100-192.168.30.199
/ip dhcp-server
add address-pool=dhcp_pool0 interface=ether2 lease-time=1d name=dhcp1
/ip address
add address=192.168.20.2/24 comment="OPNsense-LAB uplink" interface=ether1 \
    network=192.168.20.0
add address=192.168.30.1/24 comment="PC3-LAN gateway" interface=ether2 \
    network=192.168.30.0
/ip dhcp-client
add disabled=yes interface=ether1 name=client1
/ip dhcp-server network
add address=192.168.30.0/24 dns-server=1.1.1.1 gateway=192.168.30.1
/ip firewall filter
add action=accept chain=input comment=\
    "HARDENING - Allow established related input" connection-state=\
    established,related
add action=accept chain=forward comment=\
    "HARDENING - Allow established related forward" connection-state=\
    established,related
add action=drop chain=input comment="HARDENING - Drop invalid input" \
    connection-state=invalid
add action=drop chain=forward comment="HARDENING - Drop invalid forward" \
    connection-state=invalid
add action=accept chain=input comment=\
    "HARDENING - Allow management from Fedora" src-address=192.168.1.10
add action=drop chain=input comment="HARDENING - Drop all other input"
/ip route
add comment="Default via OPNsense" dst-address=0.0.0.0/0 gateway=192.168.20.1
/ip service
set ftp disabled=yes
set ssh address=192.168.1.10/32
set telnet disabled=yes
set www disabled=yes
set reverse-proxy disabled=yes
set winbox address=192.168.1.10/32
set api disabled=yes
set api-ssl disabled=yes
