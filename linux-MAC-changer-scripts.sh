#!/bin/bash
echo "[*] Network Card Down"
sudo ip link set wlan0 down
echo "[*] Generating New MAC..."
sudo macchanger -r wlan0
echo "[*] Network Card Up"
sudo ip link set wlan0 up
echo "[*] New MAC Acquired"