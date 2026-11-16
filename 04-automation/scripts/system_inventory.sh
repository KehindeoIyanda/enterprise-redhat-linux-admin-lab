#!/usr/bin/env bash

# Enterprise Linux System Inventory Script
# Lab 4.1 - Bash Automation

# Collect system information
HOSTNAME=$(hostname)
OS_NAME=$(. /etc/os-release && echo "$PRETTY_NAME")
KERNEL=$(uname -r)
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S %Z')
CPU_MODEL=$(lscpu | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
TOTAL_MEMORY=$(free -h | awk '/^Mem:/ {print $2}')
ROOT_USAGE=$(df -hP / | awk 'NR==2 {print "Size: "$2" | Used: "$3" | Available: "$4" | Usage: "$5}')
CURRENT_USER=$(whoami)

# Display the system inventory report
echo "=========================================="
echo "       ENTERPRISE LINUX SYSTEM REPORT"
echo "=========================================="

echo "Hostname:       $HOSTNAME"
echo "Operating OS:   $OS_NAME"
echo "Kernel:         $KERNEL"
echo "Date and Time:  $CURRENT_DATE"
echo "CPU Model:      $CPU_MODEL"
echo "Total Memory:   $TOTAL_MEMORY"
echo "Root Storage:   $ROOT_USAGE"
echo "Current User:   $CURRENT_USER"

echo "=========================================="
echo "       SYSTEM INVENTORY COMPLETE"
echo "=========================================="
