#!/bin/bash

THRESHOLD=5
LOG_FILE="/var/log/auth.log"

if [[ $EUID -ne 0 ]]; then
   echo "[!] Error: Please run as root (sudo ./ssh_log_analyzer.sh)"
   exit 1
fi

if [[ -f "$LOG_FILE" ]]; then
    LOGS=$(grep "Failed password" "$LOG_FILE")
elif command -v journalctl &> /dev/null; then
    LOGS=$(journalctl -u ssh -u sshd --no-pager | grep "Failed password")
else
    echo "[!] Fatal: No SSH log source found on this system."
    exit 1
fi

if [[ -z "$LOGS" ]]; then
    echo "[+] Clean: Zero failed SSH login attempts detected."
    exit 0
fi

printf "\n%-10s %-18s %-20s\n" "ATTEMPTS" "SOURCE IP" "ASSESSMENT"
echo "------------------------------------------------"

echo "$LOGS" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq -c | sort -nr | while read -r count ip; do
    if [[ "$count" -ge "$THRESHOLD" ]]; then
        printf "%-10s %-18s [ALERT] Brute-Force Suspected\n" "$count" "$ip"
    else
        printf "%-10s %-18s [INFO] Below Threshold\n" "$count" "$ip"
    fi
done
