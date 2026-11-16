#!/usr/bin/env bash

# Enterprise Linux Service Status Check
# Lab 4.3 - Bash Loops

SERVICES=("sshd" "crond" "firewalld" "NetworkManager")

echo "=========================================="
echo "       LINUX SERVICE STATUS REPORT"
echo "=========================================="

for SERVICE in "${SERVICES[@]}"; do

    if systemctl is-active --quiet "$SERVICE"; then
        echo "OK: $SERVICE is running."
    else
        echo "WARNING: $SERVICE is not running."
    fi

done

echo "=========================================="
echo "       SERVICE CHECK COMPLETE"
echo "=========================================="
