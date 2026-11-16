
# Lab 4: Enterprise Linux Automation with Bash and Shell Scripting

## 1. Lab Overview

### 1.1 Introduction

This lab focuses on automating routine Linux system administration tasks using Bash shell scripting on Rocky Linux 9.8.

The objective was to develop practical automation skills by creating reusable shell scripts for system inventory collection, disk usage monitoring, service health checks, logging, and Linux user and group administration.

The lab also introduced scheduling automated tasks with cron, debugging scripts with Bash execution tracing, and performing static code analysis with ShellCheck.

These exercises demonstrate how Linux administrators can reduce repetitive manual work, improve operational consistency, and implement repeatable system administration procedures.

### 1.2 Lab Environment

| Component | Configuration |
|---|---|
| Operating System | Rocky Linux 9.8 |
| Distribution Family | Red Hat Enterprise Linux compatible |
| Shell | GNU Bash 5.1.8 |
| Scripting Language | Bash |
| Automation Tool | Shell scripts |
| Package Manager | DNF |
| Scheduling Service | crond |
| Static Analysis Tool | ShellCheck 0.10.0 |
| Service Manager | systemd |
| Filesystem | XFS |
| Security Framework | SELinux |
| Firewall | firewalld |

### 1.3 Lab Objectives

The objectives of this exercise were to:

- Understand Bash scripting fundamentals.
- Work with variables, command substitution, and environment information.
- Implement conditional statements and logical comparisons.
- Use loops to automate repetitive administrative tasks.
- Create reusable functions.
- Automate system inventory collection.
- Monitor filesystem utilization.
- Check Linux service availability.
- Implement logging and error handling.
- Understand Bash exit codes.
- Automate basic user and group administration.
- Schedule recurring tasks using cron.
- Apply idempotency principles.
- Debug scripts using Bash execution tracing.
- Perform static analysis with ShellCheck.
- Validate scripts before deployment.

### 1.4 Directory Structure

The following directory structure was established for Lab 4:

```text
04-automation/
├── documentation/
│   └── lab-04-bash-automation.md
├── logs/
│   ├── disk_usage_cron.log
│   ├── service_monitor.log
│   └── system_inventory_20261115_202632.log
├── playbooks/
├── roles/
└── scripts/
    ├── disk_usage_check.sh
    ├── service_monitor_logger.sh
    ├── service_status_check.sh
    ├── service_status_functions.sh
    ├── system_inventory.sh
    └── user_group_automation.sh
```

**Note:** Runtime logs are retained locally for testing and evidence. They are excluded from GitHub using `.gitignore`. The existing Ansible directories were preserved for future automation exercises.

---

## 2. Bash Scripting Fundamentals

### 2.1 Introduction to Bash

Bash (Bourne Again Shell) is a command-line interpreter and scripting language commonly used for Linux system administration.

Bash scripts allow administrators to combine Linux commands into reusable programs that automate repetitive tasks.

A Bash script typically contains:

- A shebang declaration.
- Variables.
- Linux commands.
- Conditional statements.
- Loops.
- Functions.
- Input and output operations.
- Error handling.

### 2.2 Understanding the Shebang

The first line of each script uses:

```bash
#!/usr/bin/env bash
```

The shebang tells the operating system to execute the script using Bash.

The `/usr/bin/env` command locates Bash through the system's environment.

### 2.3 Creating and Executing a Bash Script

The following commands were used during the lab:

Create a script:

```bash
nano 04-automation/scripts/system_inventory.sh
```

Assign executable permission:

```bash
chmod u+x 04-automation/scripts/system_inventory.sh
```

Execute the script:

```bash
./04-automation/scripts/system_inventory.sh
```

Check script syntax:

```bash
bash -n 04-automation/scripts/system_inventory.sh
```

The `bash -n` option checks the script for syntax errors without executing its commands.

### 2.4 Understanding Bash Variables

Variables store information that can be reused throughout a script.

Example:

```bash
HOSTNAME=$(hostname)
CURRENT_USER=$(whoami)
```

Explanation:

- `HOSTNAME` stores the system hostname.
- `CURRENT_USER` stores the currently logged-in username.
- `$(command)` performs command substitution and captures command output.

Variables are referenced using the `$` prefix.

Example:

```bash
echo "$HOSTNAME"
```

### 2.5 Understanding Command Substitution

Command substitution allows a script to execute a Linux command and store its output in a variable.

Example:

```bash
KERNEL=$(uname -r)
```

The `uname -r` command retrieves the running Linux kernel version.

The returned value is assigned to the `KERNEL` variable.

---

## 3. Automated System Inventory Collection

### 3.1 Objective

The objective was to create a Bash script that automatically collects important Linux system information and displays it in a structured report.

This reduces the need to execute individual inventory commands manually.

### 3.2 Script Location

```text
04-automation/scripts/system_inventory.sh
```

### 3.3 Script Implementation

```bash
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
```

### 3.4 Commands and Utilities Used

| Command | Purpose |
|---|---|
| `hostname` | Retrieves the system hostname. |
| `uname -r` | Displays the running kernel version. |
| `date` | Retrieves the current date and time. |
| `lscpu` | Displays CPU architecture information. |
| `free -h` | Displays memory usage in human-readable format. |
| `df -hP /` | Reports root filesystem capacity and utilization. |
| `awk` | Extracts and formats selected command output. |
| `whoami` | Identifies the current effective user. |
| `/etc/os-release` | Provides Linux distribution information. |

### 3.5 Script Execution and Validation

Syntax validation:

```bash
bash -n 04-automation/scripts/system_inventory.sh
```

Execution:

```bash
./04-automation/scripts/system_inventory.sh
```

The script executed successfully and displayed the system inventory report.

### 3.6 Saving Inventory Results to a Log File

The `tee` command was used to display the report while saving a copy to a log file.

Example:

```bash
./04-automation/scripts/system_inventory.sh | tee 04-automation/logs/system_inventory_20261115_202632.log
```

The timestamped log file preserved the inventory results for later inspection.

### 3.7 Operational Benefits

Automated inventory collection provides several benefits:

- Reduces repetitive administrative work.
- Improves consistency in system reporting.
- Provides a quick system overview.
- Supports troubleshooting and capacity planning.
- Creates a record of system configuration at the time of execution.

---

## 4. Automated Disk Usage Monitoring

### 4.1 Objective

The objective was to create a Bash script that monitors root filesystem utilization and identifies when disk usage reaches a predefined threshold.

Disk monitoring is an important Linux administration responsibility because insufficient storage can affect application availability, logging, package installation, and system performance.

### 4.2 Script Location

```text
04-automation/scripts/disk_usage_check.sh
```

### 4.3 Script Implementation

```bash
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
```

### 4.4 Understanding Conditional Statements

The script uses an `if` statement to compare current disk utilization against a defined threshold.

The comparison:

```bash
if [[ "$ROOT_USAGE" -ge "$THRESHOLD" ]]; then
```

The `-ge` operator means greater than or equal to.

The script produces a warning when root filesystem utilization reaches or exceeds 80%.

Otherwise, it reports that disk utilization is within the configured limit.

### 4.5 Validation and Results

The script passed Bash syntax validation and executed successfully.

Observed result:

| Metric | Result |
|---|---:|
| Root filesystem utilization | 35% |
| Alert threshold | 80% |
| Monitoring status | OK |

The filesystem was below the configured alert threshold.

---

## 5. Linux Service Monitoring with Bash Loops

### 5.1 Objective

The objective was to automate the monitoring of important Linux services using Bash arrays and `for` loops.

Linux administrators regularly verify that essential services are running. Automating these checks reduces manual verification.

### 5.2 Script Location

```text
04-automation/scripts/service_status_check.sh
```

### 5.3 Script Implementation

```bash
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
```

### 5.4 Understanding Bash Arrays

The following line defines an array containing four Linux services:

```bash
SERVICES=("sshd" "crond" "firewalld" "NetworkManager")
```

An array allows multiple values to be stored in one variable.

### 5.5 Understanding the For Loop

The following statement processes each service in the array:

```bash
for SERVICE in "${SERVICES[@]}"; do
```

The loop assigns each service name to the `SERVICE` variable and executes the commands inside the loop.

### 5.6 Understanding systemctl

The command:

```bash
systemctl is-active --quiet "$SERVICE"
```

checks whether a systemd service is active.

- `systemctl` communicates with the systemd service manager.
- `is-active` checks the service's active state.
- `--quiet` suppresses normal command output.
- The command's exit status determines whether the service is active.

### 5.7 Validation and Results

The script passed Bash syntax validation and executed successfully.

The following services were reported as running:

| Service | Purpose | Result |
|---|---|---|
| `sshd` | Secure remote administration | Running |
| `crond` | Scheduled task execution | Running |
| `firewalld` | Firewall management | Running |
| `NetworkManager` | Network connection management | Running |

---

## 6. Reusable Bash Functions

### 6.1 Objective

The objective was to improve script organization by creating reusable Bash functions.

Functions allow administrators to group related commands into reusable blocks, reducing duplicated code and making scripts easier to maintain.

### 6.2 Script Location

```text
04-automation/scripts/service_status_functions.sh
```

### 6.3 Script Implementation

```bash
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
```

### 6.4 Understanding Function Arguments

The function:

```bash
check_service() {
    SERVICE="$1"
```

uses `$1` to access the first argument passed to the function.

For example:

```bash
check_service "sshd"
```

passes `sshd` into the function.

Inside the function, `$1` contains the service name.

### 6.5 Benefits of Functions

- Reduce repeated code.
- Improve script readability.
- Make troubleshooting easier.
- Support code reuse.
- Simplify future script modifications.

### 6.6 Validation and Results

The function-based service monitoring script passed syntax validation and executed successfully.

All four monitored services were reported as running.

The exercise demonstrated how Bash functions can make administrative automation more structured and maintainable.


---

## 7. Logging and Error Handling

### 7.1 Objective

The objective was to implement logging and error handling in Bash automation scripts.

Logging provides a historical record of script execution, while error handling helps administrators identify unsuccessful operations and respond appropriately.

### 7.2 Script Location

```text
04-automation/scripts/service_monitor_logger.sh
```

### 7.3 Script Implementation

```bash
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
```

### 7.4 Understanding the Logging Function

The `log_message` function records messages with timestamps.

```bash
log_message() {
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}
```

Explanation:

- `date` generates the current timestamp.
- `TIMESTAMP` stores the formatted date and time.
- `$1` contains the message passed to the function.
- `tee -a` displays the message and appends it to the log file.
- `LOG_FILE` defines where the monitoring records are stored.

### 7.5 Understanding Exit Codes

Linux commands and scripts return exit codes to indicate whether an operation succeeded or failed.

Common exit codes:

| Exit Code | Meaning |
|---|---|
| `0` | Successful execution |
| `1` | General error or failure |
| Other nonzero values | Additional error conditions depending on the command |

The monitoring script uses:

```bash
exit 1
```

when one or more monitored services fail.

It uses:

```bash
exit 0
```

when all monitored services are running.

### 7.6 Understanding the Failure Counter

The variable:

```bash
FAILURES=0
```

initializes a counter.

When a monitored service is inactive, the script executes:

```bash
((FAILURES++))
```

This increments the failure counter.

At the end of execution, the script evaluates the counter and determines the appropriate exit status.

### 7.7 Monitoring Log Location

```text
04-automation/logs/service_monitor.log
```

The log file stores timestamped monitoring messages.

The file was inspected using:

```bash
cat 04-automation/logs/service_monitor.log
```

The output confirmed that monitoring messages were successfully recorded.

---

## 8. Controlled Failure Testing

### 8.1 Objective

The objective was to verify that the monitoring script correctly identifies an unavailable service and returns a nonzero exit code.

Testing only successful execution is insufficient when developing reliable automation.

Scripts should also be tested under controlled failure conditions.

### 8.2 Testing Procedure

A temporary backup of the original monitoring script was created:

```bash
cp 04-automation/scripts/service_monitor_logger.sh \
04-automation/scripts/service_monitor_logger.sh.bak
```

The service array was temporarily modified to include a nonexistent service:

```bash
SERVICES=("sshd" "crond" "firewalld" "NetworkManager" "fake-service")
```

The script was then executed.

### 8.3 Expected Failure Behavior

The actual Linux services continued to report their running status.

The nonexistent `fake-service` generated a warning.

The monitoring script reported:

```text
WARNING: fake-service is not running.
Monitoring completed with 1 service failure(s).
```

The exit code was checked immediately after execution:

```bash
echo $?
```

Observed result:

```text
1
```

This confirmed that the script correctly returned a failure status.

### 8.4 Restoring the Original Script

After testing, the original script was restored:

```bash
cp 04-automation/scripts/service_monitor_logger.sh.bak \
04-automation/scripts/service_monitor_logger.sh
```

The restored script was checked again using:

```bash
bash -n 04-automation/scripts/service_monitor_logger.sh
```

The original service list was verified:

```bash
SERVICES=("sshd" "crond" "firewalld" "NetworkManager")
```

### 8.5 Testing Results

| Test | Expected Behavior | Result |
|---|---|---|
| Normal service monitoring | Exit code 0 | Passed |
| Nonexistent service | Warning displayed | Passed |
| Failure counter | Incremented to 1 | Passed |
| Controlled failure | Exit code 1 | Passed |
| Script restoration | Original service list restored | Passed |
| Syntax validation | No syntax errors | Passed |

### 8.6 Operational Importance

Controlled failure testing helps administrators verify that automation behaves correctly when unexpected conditions occur.

This is particularly important for:

- Service monitoring.
- Scheduled administrative jobs.
- Backup scripts.
- Storage monitoring.
- Application health checks.
- Production automation.


---

## 9. Linux User and Group Administration Automation

### 9.1 Objective

The objective was to develop a Bash script that automates Linux group and user creation.

User and group administration is a routine Linux system administration responsibility. Automating these operations helps improve consistency and reduces repetitive manual commands.

### 9.2 Script Location

```text
04-automation/scripts/user_group_automation.sh
```

### 9.3 Script Implementation

The following is the final improved version of the script:

```bash
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
```

### 9.4 Understanding the Script

The script uses two variables:

```bash
GROUP_NAME="automation_lab"
USER_NAME="automationuser"
```

The group and user names are defined once and reused throughout the script.

The `getent` command checks whether the group already exists:

```bash
getent group "$GROUP_NAME"
```

The `id` command checks whether the user exists:

```bash
id "$USER_NAME"
```

If the group or user does not exist, the script attempts to create it.

### 9.5 Understanding User Creation

The following command creates a Linux user:

```bash
sudo useradd -m -g "$GROUP_NAME" -s /bin/bash "$USER_NAME"
```

Explanation:

| Option | Purpose |
|---|---|
| `sudo` | Executes the command with elevated privileges. |
| `useradd` | Creates a Linux user account. |
| `-m` | Creates the user's home directory. |
| `-g` | Assigns the primary group. |
| `-s` | Specifies the login shell. |
| `/bin/bash` | Sets Bash as the user's login shell. |

The script uses direct command checks inside `if` statements to handle success and failure.

For example:

```bash
if sudo groupadd "$GROUP_NAME"; then
```

This is preferable to checking `$?` separately because it evaluates the command's exit status directly.

### 9.6 User and Group Verification

The automation script successfully created:

- Group: `automation_lab`
- User: `automationuser`

The account was verified using:

```bash
id automationuser
```

The observed result was:

```text
uid=1004(automationuser) gid=1004(automation_lab) groups=1004(automation_lab)
```

The group was verified using:

```bash
getent group automation_lab
```

The observed result was:

```text
automation_lab:x:1004:
```

The home directory was verified using:

```bash
ls -ld /home/automationuser
```

The observed result confirmed:

```text
drwx------. 3 automationuser automation_lab 92 Nov 15 21:43 /home/automationuser
```

Group membership was also verified:

```bash
groups automationuser
```

Result:

```text
automationuser : automation_lab
```

### 9.7 Security Considerations

The automation account was created with:

- A dedicated primary group.
- A private home directory with mode `700`.
- Bash as its login shell.
- No additional administrative group membership.

The script does not configure a password or grant unnecessary sudo privileges.

---

## 10. Idempotency Testing

### 10.1 Understanding Idempotency

Idempotency is an important principle in system administration and infrastructure automation.

An idempotent operation can be executed repeatedly without creating unnecessary duplicate resources or changing an already-correct state.

### 10.2 Practical Test

After creating the user and group, the automation script was executed again:

```bash
./04-automation/scripts/user_group_automation.sh
```

Observed output:

```text
INFO: Group automation_lab already exists.
INFO: User automationuser already exists.
User and group automation completed.
```

### 10.3 Test Results

The second execution confirmed that:

- The existing group was detected.
- The existing user was detected.
- No duplicate group was created.
- No duplicate user was created.
- The script completed successfully.

This demonstrated basic idempotent behavior.

**Limitation:** The script checks whether the account and group exist. It does not reconcile incorrect ownership, group membership, login shell, or other existing account settings. Therefore, it demonstrates basic existence-based idempotency rather than full configuration-state enforcement.

---

## 11. Bash Debugging and Execution Tracing

### 11.1 Objective

The objective was to understand how to troubleshoot Bash scripts using execution tracing.

Debugging helps administrators identify the sequence of commands executed by a script and investigate unexpected behavior.

### 11.2 Debugging Command

The following command was used:

```bash
bash -x ./04-automation/scripts/user_group_automation.sh
```

The `-x` option enables execution tracing.

Bash displays each command before executing it, using a `+` prefix.

### 11.3 Observed Debugging Output

The output confirmed that Bash:

1. Assigned the group name.
2. Assigned the username.
3. Checked whether the group existed.
4. Checked whether the user existed.
5. Displayed the appropriate informational messages.
6. Displayed the completion message.

### 11.4 Debugging Lessons

The exercise also demonstrated an important distinction between script variables and interactive shell variables.

When the following command was executed directly in the terminal:

```bash
sudo groupadd "$GROUP_NAME"
```

the command failed because `GROUP_NAME` was defined inside the script, not in the interactive shell.

Bash therefore expanded the undefined variable to an empty string.

The resulting error was:

```text
groupadd: '' is not a valid group name
```

An unfinished `if` statement also caused Bash to display its secondary `>` prompt. The operation was cancelled using `Ctrl+C`.

This exercise demonstrated the importance of understanding variable scope and Bash command syntax.

---

## 12. Automated Task Scheduling with Cron

### 12.1 Objective

The objective was to schedule a recurring disk monitoring task using the Linux cron service.

Cron allows administrators to execute scripts automatically at predefined times without manually starting them.

### 12.2 Verify the Cron Service

The cron daemon was checked using:

```bash
systemctl status crond
```

The service was confirmed to be enabled and active.

### 12.3 Inspect Existing Cron Jobs

The current user's cron table was inspected using:

```bash
crontab -l
```

Initially, no user-specific cron jobs were configured.

### 12.4 Configure a Temporary Cron Job

The following entry was added using:

```bash
crontab -e
```

Cron entry:

```cron
*/5 * * * * /home/****/enterprise-redhat-linux-admin-lab/04-automation/scripts/disk_usage_check.sh >> /home/****/enterprise-redhat-linux-admin-lab/04-automation/logs/disk_usage_cron.log 2>&1
```

### 12.5 Understanding Cron Syntax

The five scheduling fields represent:

```text
Minute  Hour  Day-of-Month  Month  Day-of-Week
```

The expression:

```cron
*/5 * * * *
```

means that the script runs every five minutes.

The remaining fields use `*`, meaning every applicable hour, day, month, and weekday.

### 12.6 Understanding Output Redirection

The command uses:

```bash
>> /path/to/logfile 2>&1
```

Explanation:

- `>>` appends standard output to the log file.
- `2>&1` redirects standard error to the same destination as standard output.
- Both normal output and error messages are therefore captured.

### 12.7 Cron Execution Verification

The temporary cron job was allowed to execute over approximately six minutes.

The resulting log file contained two complete disk monitoring reports.

The reports showed:

- Root filesystem utilization of 35%.
- Configured alert threshold of 80%.
- Monitoring status of OK.

This confirmed that cron executed the script automatically.

### 12.8 Removing the Temporary Cron Job

After successful testing, the temporary cron entry was removed using:

```bash
crontab -e
```

The cron table was checked again:

```bash
crontab -l
```

No user-specific cron entries remained.

The `crond` service remained active.

The exercise demonstrated both scheduled execution and proper removal of temporary test configuration.

---

## 13. Static Code Analysis with ShellCheck

### 13.1 Overview

ShellCheck is a static analysis tool for shell scripts. It identifies common scripting errors, quoting problems, portability issues, and coding practices that could lead to unexpected behavior.

It was used to review all six Bash scripts created during this lab.

### 13.2 Installation

ShellCheck was available through the Extra Packages for Enterprise Linux (EPEL) repository.

Install the package:

```bash
sudo dnf install ShellCheck -y
```
Verify the installation:

```bash
shellcheck --version
```

The installed version was:

```text
0.10.0
```
### 13.3 Initial Script Review

Run ShellCheck against the user and group automation script:

```bash
shellcheck 04-automation/scripts/user_group_automation.sh
```

The initial review identified ShellCheck warning SC2181 in two locations.

SC2181 recommends checking a command directly inside an `if` statement instead of checking its exit status afterward with `$?`.

The script was improved to use direct conditional checks.

Example:

```bash
if sudo groupadd "$GROUP_NAME"; then
    echo "OK: Group $GROUP_NAME created."
else
    echo "ERROR: Unable to create group $GROUP_NAME."
    exit 1
fi
```

The same approach was applied to user creation.
### 13.3 Initial Script Review

Run ShellCheck against the user and group automation script:

```bash
shellcheck 04-automation/scripts/user_group_automation.sh
```

The initial review identified ShellCheck warning SC2181 in two locations.

SC2181 recommends checking a command directly inside an `if` statement instead of checking its exit status afterward with `$?`.

The script was improved to use direct conditional checks.

Example:

```bash
if sudo groupadd "$GROUP_NAME"; then
    echo "OK: Group $GROUP_NAME created."
else
    echo "ERROR: Unable to create group $GROUP_NAME."
    exit 1
fi
```

The same approach was applied to user creation.
### 13.4 Validate All Scripts

Run ShellCheck against all six scripts:

```bash
shellcheck -x 04-automation/scripts/*.sh
```

The command completed without reporting any findings.

The `-x` option allows ShellCheck to follow sourced files where possible.

**Result:** All six scripts passed the final ShellCheck review.
---

## 14. Bash Syntax Validation

Each script was checked for Bash syntax errors using `bash -n`.

Run the validation loop:

```bash
for script in 04-automation/scripts/*.sh; do
    echo "Checking: $script"
    bash -n "$script" || break
done
```

The output listed all six scripts without reporting syntax errors.

### Validation Results

| Script | Syntax Check |
|---|---|
| system_inventory.sh | Passed |
| disk_usage_check.sh | Passed |
| service_status_check.sh | Passed |
| service_status_functions.sh | Passed |
| service_monitor_logger.sh | Passed |
| user_group_automation.sh | Passed |

**Result:** All six Bash scripts passed syntax validation and static analysis.
---

## 15. Script Permissions and File Organization

The scripts were made executable using:

```bash
chmod u+x 04-automation/scripts/*.sh
```

Verify permissions:

```bash
ls -l 04-automation/scripts/
```

The scripts have executable permission for their owner.

The permission mode is equivalent to `744`:

- Owner: read, write, and execute.
- Group: read only.
- Others: read only.

This is sufficient for the current lab because the scripts are executed by their owner.

For shared environments where other users need to execute the scripts, permissions may be adjusted to `755`, subject to the organization's access policy.

### Final Script Inventory

```text
04-automation/scripts/
├── disk_usage_check.sh
├── service_monitor_logger.sh
├── service_status_check.sh
├── service_status_functions.sh
├── system_inventory.sh
└── user_group_automation.sh
```
---

## 16. Git Ignore Configuration

Runtime logs were generated during the exercises. These logs contain environment-specific information and are not required in the public GitHub repository.

The root `.gitignore` file was updated with:

```gitignore
# Local virtual disk images used for storage labs
03-storage-management/images/*.img

# Runtime logs generated by automation exercises
04-automation/logs/*.log

# Temporary backup created during controlled failure testing
04-automation/scripts/*.bak
```

Verify the ignore rules:

```bash
git check-ignore -v 04-automation/logs/*.log
```

The command confirmed that the runtime log files are ignored by Git.

The temporary backup file used during controlled failure testing was deleted after the original script was restored.

**Result:** Runtime logs and temporary backup files are excluded from version control. The virtual disk image from Lab 3 remains excluded as well.
---

## 17. Security and Operational Considerations

The following practices were observed throughout the lab:

1. Administrative operations were performed with `sudo` where required.
2. User passwords were not stored in scripts or documentation.
3. The automation account was created without additional administrative privileges.
4. Scripts use quoted variables to reduce problems caused by spaces or special characters.
5. Service checks use `systemctl` to inspect service activity.
6. Disk monitoring uses an 80% threshold to identify high filesystem usage.
7. Runtime logs are excluded from the public repository.
8. Temporary test files were removed after testing.
9. Private network details and machine-specific identifiers are excluded from public documentation.

### Known Script Limitations

These scripts demonstrate foundational automation techniques. They are not yet full enterprise monitoring solutions.

| Script | Current Limitation |
|---|---|
| system_inventory.sh | Collects a basic system inventory rather than a complete asset report. |
| disk_usage_check.sh | Checks only the root filesystem and uses a fixed 80% threshold. |
| service_status_check.sh | Monitors only four predefined services. |
| service_status_functions.sh | Uses a predefined service list rather than accepting external configuration. |
| service_monitor_logger.sh | Uses a project-relative log path and should be run from the project root for that path to resolve correctly. |
| user_group_automation.sh | Uses fixed account names and checks whether accounts exist, but does not reconcile every account attribute. |

The temporary cron job used to test scheduled execution was removed after verification. No recurring user cron job was left behind.

Future improvements could include configurable thresholds, command-line arguments, stronger input validation, script-relative log paths, structured logging, and alert notifications.
---

## 18. Lessons Learned

During this lab, the following Linux administration and automation concepts were practiced:

- Bash scripting fundamentals, including shebangs and variables.
- Command substitution and collecting system information.
- Conditional statements and numeric comparisons.
- Bash arrays and `for` loops.
- Creating and calling reusable functions.
- Passing arguments to functions.
- Logging messages with timestamps.
- Handling script exit codes.
- Testing controlled failures.
- Automating Linux user and group creation.
- Designing basic idempotent scripts.
- Scheduling tasks with cron.
- Debugging scripts with `bash -x`.
- Performing static analysis with ShellCheck.
- Validating Bash syntax with `bash -n`.
- Managing script permissions and Git ignore rules.

The lab demonstrated how routine Linux administration tasks can be converted into repeatable Bash automation scripts.
---

## 19. Conclusion

Lab 4 successfully demonstrated foundational enterprise Linux automation using Bash and shell scripting on Rocky Linux 9.8.

Six executable scripts were developed and tested. Additional exercises covered logging, error handling, user and group automation, scheduled execution, debugging, and static code analysis.

All six scripts passed Bash syntax validation and the final ShellCheck review.

The practical exercises provided experience in reducing repetitive administrative work, improving consistency, and validating automation before use.

This lab establishes a foundation for more advanced Linux automation using Ansible, configuration management, monitoring, and operational scripting.
