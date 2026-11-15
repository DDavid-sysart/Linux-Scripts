#!/bin/bash

IFACE=${1:-wlan0}


cleanup() {
    echo -e "\n\e[33m[*] Ctrl+C Monitor Mode DOWN $IFACE...\e[0m"
    sudo ip link set $IFACE down
    sudo iw dev $IFACE set type managed
    sudo ip link set $IFACE up
    
    echo -e "\e[33m[*] Restart NetworkManager ...\e[0m"
    sudo systemctl restart NetworkManager
    
    echo -e "\e[32m[*] Back Online. Love you!\e[0m"
    exit 0
}


trap cleanup SIGINT


echo -e "\e[32m[*] Interface Processes Down...\e[0m"
sudo airmon-ng check kill > /dev/null 2>&1

echo -e "\e[32m[*] Monitor Mode UP...\e[0m"
sudo ip link set $IFACE down
sudo iw dev $IFACE set type monitor
sudo ip link set $IFACE up

echo -e "\e[32m[*] Leave airodump-ng. Ctrl+C to EXIT.\e[0m"
sudo airodump-ng $IFACE


cleanup