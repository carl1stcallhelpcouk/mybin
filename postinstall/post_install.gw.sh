#!/bin/bash
printf "%s\n\n" "Updating /etc/network/interfaces."

cat<<EOF | sudo tee -a /etc/network/interfaces

##### VM Network Interfaces
allow-hotplug eth1
iface eth1 inet static
	address	192.168.1.1
	netmask	255.255.255.0	
	network	192.168.1.0	
	broadcast 192.168.1.255
	gateway	192.168.1.1
EOF
sudo ifup eth1