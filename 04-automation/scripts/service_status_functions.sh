#!/usr/bin/env bash

# Enterprise Linux Service Monitoring
# Lab 4.4 - Bash Functions

# Function 1: Display report header
print_header() {
    echo "=========================================="
    echo "       LINUX SERVICE STATUS REPORT"
    echo "=========================================="
}

# Function 2: Check individual service
check_service() {
    SERVICE="$1"

    if systemctl is-active --quiet "$SERVICE"; then
        echo "OK: $SERVICE is running."
    else
        echo "WARNING: $SERVICE is not running."
    fi
}

# Function 3: Display report footer
print_footer() {
    echo "=========================================="
    echo "       SERVICE CHECK COMPLETE"
    echo "=========================================="
}

# List services to monitor
SERVICES=("sshd" "crond" "firewalld" "NetworkManager")

# Execute functions
print_header

for SERVICE in "${SERVICES[@]}"; do
    check_service "$SERVICE"
done

print_footer
