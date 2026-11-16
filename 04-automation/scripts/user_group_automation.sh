#!/usr/bin/env bash

# Enterprise Linux User and Group Automation
# Lab 4.8 - User and Group Administration

GROUP_NAME="automation_lab"
USER_NAME="automationuser"

# Check whether the group exists
if getent group "$GROUP_NAME" > /dev/null; then
    echo "INFO: Group $GROUP_NAME already exists."
else
    if sudo groupadd "$GROUP_NAME"; then
        echo "OK: Group $GROUP_NAME created."
    else
        echo "ERROR: Unable to create group $GROUP_NAME."
        exit 1
    fi
fi

# Check whether the user exists
if id "$USER_NAME" > /dev/null 2>&1; then
    echo "INFO: User $USER_NAME already exists."
else
    if sudo useradd -m -g "$GROUP_NAME" -s /bin/bash "$USER_NAME"; then
        echo "OK: User $USER_NAME created."
    else
        echo "ERROR: Unable to create user $USER_NAME."
        exit 1
    fi
fi

echo "User and group automation completed."
