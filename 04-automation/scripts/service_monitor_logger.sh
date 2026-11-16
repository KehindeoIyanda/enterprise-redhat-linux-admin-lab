#!/usr/bin/env bash

# Enterprise Linux Service Monitoring
# Lab 4.5 - Logging and Error Handling

LOG_FILE="04-automation/logs/service_monitor.log"

SERVICES=("sshd" "crond" "firewalld" "NetworkManager")

# Function to write messages to the log
log_message() {
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

# Track service failures
FAILURES=0

log_message "Starting service monitoring."

for SERVICE in "${SERVICES[@]}"; do

    if systemctl is-active --quiet "$SERVICE"; then
        log_message "OK: $SERVICE is running."
    else
        log_message "WARNING: $SERVICE is not running."
        ((FAILURES++))
    fi

done

if [[ "$FAILURES" -gt 0 ]]; then
    log_message "Monitoring completed with $FAILURES service failure(s)."
    exit 1
else
    log_message "Monitoring completed successfully. All services are running."
    exit 0
fi
