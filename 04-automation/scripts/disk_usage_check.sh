#!/usr/bin/env bash

# Enterprise Linux Disk Usage Monitoring
# Lab 4.2 - Variables and Conditional Statements

# Define variables
HOSTNAME=$(hostname)
ROOT_USAGE=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
THRESHOLD=80

# Display monitoring results
echo "=========================================="
echo "       DISK USAGE MONITORING"
echo "=========================================="

echo "Hostname: $HOSTNAME"
echo "Root Disk Usage: ${ROOT_USAGE}%"
echo "Alert Threshold: ${THRESHOLD}%"

# Check disk usage
if [[ "$ROOT_USAGE" -ge "$THRESHOLD" ]]; then
    echo "WARNING: Root filesystem usage is high!"
else
    echo "OK: Root filesystem usage is within limits."
fi

echo "=========================================="
echo "       MONITORING COMPLETE"
echo "=========================================="
