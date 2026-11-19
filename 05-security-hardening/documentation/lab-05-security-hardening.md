# Lab 05 – Enterprise Linux Security Hardening

## 1. Project Overview

This lab demonstrates practical Linux security administration and hardening techniques on a Rocky Linux 9.8 system.

The objective was to assess the existing security configuration, identify areas for improvement, apply appropriate security controls, and validate the results.

The exercises focused on protecting remote administrative access, reducing unnecessary network exposure, enforcing least-privilege access, validating SELinux controls, reviewing password policies, and monitoring security-related events through Linux Audit.

The lab follows a defense-in-depth approach. This means using multiple security controls together rather than depending on a single security feature.

## 2. Lab Objectives

The objectives of this lab were to:

- Assess the existing Linux security configuration.
- Configure SSH for public-key authentication and disable password-based remote login.
- Disable direct root SSH access.
- Review firewall rules and reduce unnecessary network exposure.
- Restrict MariaDB network access to the local system.
- Verify SELinux enforcement and practice file-context management.
- Implement least-privilege sudo permissions.
- Review password aging, password quality, and account lockout configuration.
- Use Linux Audit to monitor file modifications and permission changes.
- Validate security settings and document the results.

## 3. Lab Environment

| Component | Configuration |
|---|---|
| Operating System | Rocky Linux 9.8 (Blue Onyx) |
| Kernel | Linux 5.14.x |
| Architecture | x86_64 |
| Shell | Bash |
| Security Framework | SELinux |
| Firewall | firewalld |
| Remote Administration | OpenSSH |
| Database Service | MariaDB |
| Access Control | sudo |
| Auditing | auditd |
| Service Management | systemd |
| Package Management | DNF / RPM |

### 3.1 Security Tools Used

| Tool | Purpose |
|---|---|
| `systemctl` | Manage and inspect Linux services |
| `sshd` | Configure and validate SSH server security |
| `ssh-keygen` | Generate SSH authentication keys |
| `firewall-cmd` | Manage firewall rules |
| `ss` | Inspect listening network sockets |
| `getenforce` | Check SELinux enforcement mode |
| `semanage` | Manage SELinux policy mappings |
| `restorecon` | Restore default SELinux file contexts |
| `visudo` | Validate sudo policy configuration |
| `chage` | Inspect password aging policies |
| `faillock` | Inspect account lockout records |
| `auditctl` | Manage active audit rules |
| `ausearch` | Search Linux audit records |
| `auditctl -s` | Inspect kernel audit status |

## 4. Security Baseline Assessment

Before making security changes, the existing system configuration was inspected to establish a security baseline.

The assessment covered SELinux, firewalld, SSH, administrative privileges, and critical system services.

### 4.1 Initial Security Status

| Security Component | Initial Status | Assessment |
|---|---|---|
| SELinux | Enforcing | Security policy actively enforced |
| firewalld | Active and enabled | Host firewall operational |
| SSH service | Active and enabled | Remote administration available |
| SSH root login | Not yet hardened | Required configuration review |
| SSH password authentication | Not yet hardened | Required configuration review |
| MariaDB listener | All network interfaces | Required exposure reduction |
| Cockpit firewall access | Allowed | Unnecessary firewall permission identified |
| Kernel IP forwarding | Disabled | Host not configured as a router |
| Audit daemon | Active and enabled | Audit service operational |
| Active audit rules | None | No custom event-monitoring rules loaded |

### 4.2 Baseline Commands

The following commands were used to inspect the system:

```bash
cat /etc/rocky-release
uname -r
getenforce
sestatus
sudo systemctl status firewalld --no-pager
sudo systemctl status sshd --no-pager
sudo ss -tulpn
sudo auditctl -s
sudo auditctl -l
```
### 4.3 Baseline Findings
The assessment confirmed that SELinux was already enforcing its targeted security policy and firewalld was running.

The SSH service was enabled and listening for remote connections. However, SSH authentication settings required hardening.

MariaDB was initially listening on all network interfaces, creating unnecessary network exposure for a database that could operate locally.

Cockpit was not running, but its service was still permitted through the firewall.

The audit daemon was operational, but no active custom audit rules were loaded.

These findings established the areas that would be addressed during the security-hardening exercises.


## 5. SSH Server Hardening

SSH (Secure Shell) provides encrypted remote access to Linux servers. Securing SSH is important because unauthorized remote access can expose an entire system to compromise.

The objective of this exercise was to strengthen SSH authentication, prevent direct root login, and reduce unnecessary remote access capabilities.

### 5.1 Configuration Backup

Before making changes, the original SSH configuration was backed up:

```bash
sudo cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config.pre-lab5
```

A dedicated SSH configuration drop-in file was created:

`/etc/ssh/sshd_config.d/00-lab5-hardening.conf`

### 5.2 SSH Security Settings

The following settings were applied:

```text
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitEmptyPasswords no
MaxAuthTries 3
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
```


### 5.3 Explanation of Configuration Settings

| Setting | Security Purpose |
|---|---|
| `PermitRootLogin no` | Prevents direct root SSH login |
| `PubkeyAuthentication yes` | Enables public-key authentication |
| `PasswordAuthentication no` | Disables SSH password authentication |
| `KbdInteractiveAuthentication no` | Disables keyboard-interactive authentication |
| `PermitEmptyPasswords no` | Prevents empty-password authentication |
| `MaxAuthTries 3` | Limits authentication attempts per connection |
| `LoginGraceTime 30` | Limits the authentication time window to 30 seconds |
| `ClientAliveInterval 300` | Sends a client-alive probe every 300 seconds |
| `ClientAliveCountMax 2` | Disconnects after two unanswered probes |
| `X11Forwarding no` | Disables X11 forwarding |

The client-alive settings help detect unresponsive SSH clients. They are not a strict user inactivity timeout.


### 5.4 Configuration Validation

The SSH configuration was validated before reloading the service:

```bash
sudo sshd -t
sudo sshd -T
```

The syntax check completed without errors. The effective configuration was inspected to confirm that the intended security settings were active.

The SSH service was reloaded and subsequently verified as active.

### 5.5 Authentication Testing

Public-key authentication was tested from a Windows client. A new SSH session was successfully established using the configured private key without entering the Linux account password.

Password-only authentication was tested separately:

```powershell
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no ADMIN_USER@SERVER_IP
```

The server rejected the connection:

```text
Permission denied (publickey).
```

This confirmed that password-only SSH authentication was disabled while public-key authentication remained functional.


### 5.6 Results and Security Benefits

The SSH hardening exercise achieved the following:

- Enabled public-key-based remote authentication.
- Disabled SSH password authentication.
- Prevented direct root SSH login.
- Limited authentication attempts to three per connection.
- Restricted unnecessary SSH forwarding capabilities.
- Preserved administrative access through verified SSH keys.

A fresh SSH connection using public-key authentication succeeded after the configuration reload. Password-only authentication was rejected as expected.

The original SSH configuration backup was retained for recovery purposes.

The SSH hardening exercise improved remote access security while preserving legitimate administrative access.


## 6. Firewall and Network Exposure Hardening

A Linux firewall controls which network connections are allowed to reach a server.

The purpose of this exercise was to reduce unnecessary network exposure while preserving the services required for normal system operation.

The hardening activities focused on restricting database access to the local system, removing unnecessary Cockpit firewall access, and disabling network forwarding.

### 6.1 Initial Network Exposure Assessment

The initial inspection identified several network services and firewall permissions that required review.

| Component | Initial Condition | Security Concern |
|---|---|---|
| MariaDB | Listening on all network interfaces | Database unnecessarily exposed to the network |
| Cockpit | Firewall service permitted | Unnecessary remote administration access |
| IP forwarding | Disabled at kernel level | No routing requirement identified |
| SSH | Firewall access permitted | Required for secure remote administration |
| HTTP | Firewall access permitted | Required for the existing web application |

The firewall was managed using `firewalld`, with the `public` zone active.


### 6.2 MariaDB Network Access Restriction

The initial network inspection showed that MariaDB was listening on all network interfaces through TCP port 3306.

Because the database was being accessed locally by applications running on the same server, external network access was unnecessary.

Before changing the configuration, backups of the existing MariaDB configuration files were created:

```bash
sudo cp -a /etc/my.cnf /root/my.cnf.pre-lab5
sudo cp -a /etc/my.cnf.d/mariadb-server.cnf /root/mariadb-server.cnf.pre-lab5
```

A dedicated configuration file was created:

`/etc/my.cnf.d/99-lab5-security.cnf`

The following setting was applied:

```ini
[mysqld]
bind-address=127.0.0.1
```

This restricted MariaDB network listening to the local loopback interface.

The MariaDB service was restarted successfully after the configuration change.

#### Verification

The listening address was checked using:

```bash
sudo ss -tulpn | grep ':3306'
```

The output confirmed that MariaDB was listening on:

```text
127.0.0.1:3306
```

The database configuration was also inspected through SQL, confirming that `bind_address` was set to `127.0.0.1`.

The existing `librarydb` database and its `books` table remained accessible. Apache also continued returning HTTP 200 responses from the local web application.

#### Security Benefit

Restricting MariaDB to localhost reduced unnecessary network exposure and prevented remote clients from connecting directly to the database through its TCP listener.


### 6.3 Cockpit Firewall Access Removal

Cockpit is a web-based Linux server administration interface.

During the initial assessment, Cockpit was inactive, but its service was still permitted through the active firewall zone.

Because Cockpit was not required for this lab, its firewall permission was removed.

The following commands were used:

```bash
sudo firewall-cmd --zone=public --remove-service=cockpit
sudo firewall-cmd --permanent --zone=public --remove-service=cockpit
```

Both commands completed successfully.

The Cockpit service was not uninstalled. Only its firewall permission was removed.

### 6.4 Network Forwarding Restriction

IP forwarding allows a Linux system to pass network traffic between interfaces.

The initial assessment confirmed that IPv4 and IPv6 kernel forwarding were already disabled.

The active and permanent firewalld configurations were also updated to disable forwarding in the public zone:

```bash
sudo firewall-cmd --zone=public --remove-forward
sudo firewall-cmd --permanent --zone=public --remove-forward
```

Both operations completed successfully.

This maintained the server's role as a normal host rather than a network router.


### 6.5 Final Firewall Configuration

After the firewall changes, both the active and permanent public-zone configurations were inspected.

The final firewall configuration contained the following permitted services:

| Firewall Service | Status | Purpose |
|---|---|---|
| `ssh` | Allowed | Secure remote administration |
| `http` | Allowed | Existing web application access |
| `dhcpv6-client` | Allowed | DHCPv6 network configuration |
| `cockpit` | Removed | Unnecessary remote administration access |

Additional verification confirmed:

- Firewall forwarding was disabled.
- IP masquerading was disabled.
- No unnecessary custom ports or rich rules were present.
- SSH access remained permitted.
- HTTP access remained permitted.
- Active and permanent firewall configurations matched.

The firewall remained active throughout the exercise.

### 6.6 Results and Security Benefits

The firewall and network exposure hardening exercise achieved the following:

- Restricted MariaDB to the local loopback interface.
- Removed unnecessary Cockpit firewall access.
- Disabled firewall forwarding in the public zone.
- Preserved required SSH and HTTP connectivity.
- Verified that active and permanent firewall configurations matched.
- Confirmed that the existing database and web application continued operating.

These changes reduced unnecessary network exposure while preserving the services required by the server.


## 7. SELinux Security Hardening

Security-Enhanced Linux (SELinux) is a Linux security mechanism that provides mandatory access control (MAC).

Unlike traditional Linux permissions, which primarily control access through users, groups, and file permissions, SELinux applies additional security rules to processes and resources.

The objective of this exercise was to inspect SELinux enforcement, verify security contexts, and demonstrate how file-context labels influence application access.

### 7.1 SELinux Security Baseline

The initial assessment confirmed that SELinux was enabled and operating in enforcing mode.

The system used the targeted SELinux policy.

The following commands were used to inspect the SELinux configuration:

```bash
getenforce
sestatus
```

The output confirmed:

| SELinux Component | Observed Configuration |
|---|---|
| SELinux status | Enabled |
| Current mode | Enforcing |
| Configured mode | Enforcing |
| Policy type | Targeted |

SELinux remained in enforcing mode throughout the exercise. It was not disabled or placed into permissive mode.


### 7.2 SELinux File Context Inspection

SELinux uses security labels to control how applications interact with files and directories.

The following commands were used to inspect important system paths:

```bash id="6fpl3z"
ls -Zd /var/www/html
ls -Zd /var/lib/mysql
ls -Z /etc/my.cnf.d/99-lab5-security.cnf
```

The inspection confirmed the following expected SELinux types:

| Resource | SELinux Type | Purpose |
|---|---|---|
| `/var/www/html` | `httpd_sys_content_t` | Apache web content |
| `/var/lib/mysql` | `mysqld_db_t` | MariaDB database files |
| MariaDB security configuration | `mysqld_etc_t` | MariaDB configuration files |

The expected file contexts were also checked using:

```bash id="ukv0zw"
sudo matchpathcon -V /var/www/html
sudo matchpathcon -V /var/lib/mysql
sudo matchpathcon -V /etc/my.cnf.d/99-lab5-security.cnf
```

The checks confirmed that the inspected paths matched their expected SELinux file-context definitions.

### 7.3 SELinux Process Domain Inspection

SELinux also assigns security domains to running processes.

The following commands were used to inspect the Apache, PHP-FPM, and MariaDB process contexts:

```bash id="j65rjr"
ps -eZ | grep httpd
ps -eZ | grep php-fpm
ps -eZ | grep mariadbd
```

The inspection showed:

| Service | SELinux Process Domain |
|---|---|
| Apache HTTP Server | `httpd_t` |
| PHP-FPM | `httpd_t` |
| MariaDB | `mysqld_t` |

These process domains help enforce isolation between system services.


### 7.4 Custom SELinux File-Context Mapping

A controlled exercise was performed to demonstrate how SELinux file-context mappings work.

A temporary directory was created:

```bash
sudo mkdir -p /srv/selinux-lab
```

The directory initially used the default `var_t` SELinux type.

A custom file-context rule was added to assign the Apache content type:

```bash
sudo semanage fcontext -a -t httpd_sys_content_t '/srv/selinux-lab(/.*)?'
```

The new mapping was applied using:

```bash
sudo restorecon -Rv /srv/selinux-lab
```

The resulting SELinux context was inspected and verified.

A temporary static HTML page was created inside the directory. Apache was configured with a temporary URL alias pointing to the test directory.

### 7.5 Apache Access Verification

Before reloading Apache, its configuration was validated:

```bash
sudo apachectl configtest
```

The configuration test returned:

```text
Syntax OK
```

Apache was reloaded successfully.

The test page was accessed locally:

```bash
curl -i http://127.0.0.1/selinux-lab/
```

The request returned:

```text
HTTP/1.1 200 OK
```

This demonstrated that Apache could access and serve content from the custom-labeled directory while SELinux remained in enforcing mode.


### 7.6 SELinux Test Cleanup

After the access test was completed, the temporary Apache configuration was removed.

Apache configuration syntax was checked again, and the service was reloaded successfully.

The temporary custom SELinux file-context mapping was deleted:

```bash id="p7h8k2"
sudo semanage fcontext -d '/srv/selinux-lab(/.*)?'
```

The temporary test directory was also removed:

```bash id="d5h3s8"
sudo rm -rf /srv/selinux-lab
```

The test resources were removed, and no custom file-context mappings from this exercise remained.

### 7.7 SELinux Audit Inspection

SELinux audit events were inspected using:

```bash id="g8j4m2"
sudo ausearch -m AVC,USER_AVC -ts recent
```

The command returned:

```text id="f3w6n1"
<no matches>
```

No AVC or USER_AVC denial records were found during the inspection.

### 7.8 Final SELinux Verification

The final checks confirmed that:

- SELinux remained enabled and enforcing.
- The targeted policy remained active.
- Apache remained operational.
- MariaDB retained its expected security context.
- The original system file-context definitions remained valid.
- Temporary Apache configuration and SELinux test resources were removed.
- No custom file-context mappings from the exercise remained.

No SELinux booleans were changed because no application requirement justified expanding service privileges.


## 8. Sudo Privilege Management

Sudo allows authorized users to execute specific commands with elevated privileges.

The principle of least privilege requires administrators to grant only the permissions necessary for a user to perform assigned tasks.

The objective of this exercise was to inspect existing sudo permissions and create a restricted administrative policy for a non-administrative account.

### 8.1 Initial Sudo Configuration Assessment

The existing sudo configuration was inspected before making changes.

The following command was used to validate the sudo policy:

```bash
sudo visudo -c
```

The validation completed successfully.

The system's existing administrative group was also inspected. Members of the `wheel` group retained their existing administrative permissions.

The `/etc/sudoers.d/` directory was initially empty, making it suitable for a dedicated restricted policy.


### 8.2 Creating a Restricted Sudo Policy

A dedicated sudoers configuration file was created:

`/etc/sudoers.d/automationuser`

The following rule was added:

```sudoers
automationuser ALL=(root) NOPASSWD: /usr/bin/systemctl --no-pager status httpd
```

This rule grants the specified account permission to execute one approved Apache service-status command as root without entering a password.

The policy was configured with the required file permissions:

```bash id="z8r3v1"
sudo chmod 0440 /etc/sudoers.d/automationuser
```

The file was assigned restrictive permissions because sudo requires correctly protected policy files.

### 8.3 Sudo Policy Validation

The sudo configuration was validated after creating the restricted rule:

```bash id="v4k2m6"
sudo visudo -c
sudo -l -U automationuser
```

The validation confirmed that the main sudoers file and the dedicated policy file were parsed successfully.

The account's permitted command list showed only the approved Apache status command.


### 8.4 Testing Restricted Sudo Permissions

The restricted account was accessed to test the sudo policy:

```bash
sudo -iu automationuser
whoami
```

The `whoami` command confirmed that the active account was `automationuser`.

The approved Apache status command was executed without a password:

```bash
sudo -n /usr/bin/systemctl --no-pager status httpd
```

The command completed successfully and confirmed that the Apache service was active.

Additional commands were tested to verify that the account did not receive unrestricted administrative access:

```bash
sudo -n /usr/bin/id
sudo -n /usr/bin/systemctl --no-pager status sshd
```

Both commands were denied and did not execute with root privileges.

The account was then exited, and the existing administrator's sudo access was verified separately.

### 8.5 Results and Security Benefits

The exercise demonstrated the following security controls:

- A dedicated sudoers policy was created for a non-administrative account.
- The account received permission to execute one specific administrative command.
- The approved command ran without requiring a password.
- Unapproved administrative commands were denied.
- Existing administrator privileges remained functional.

This approach demonstrates the principle of least privilege by limiting elevated access to a clearly defined operational task.


## 9. Password and Account Security Policies

Password and account policies help protect Linux systems against unauthorized access.

This exercise focused on inspecting password-aging settings, password-quality controls, account-lockout configuration, and existing account expiration policies.

The assessment was performed without modifying existing password or authentication settings.

### 9.1 Password Aging Defaults

The `/etc/login.defs` file was inspected to identify the system's default password-aging settings.

The following command was used:

```bash
sudo grep -nE '^(PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE|PASS_MIN_LEN)' /etc/login.defs
```

The inspection identified these settings:

| Setting | Value | Description |
|---|---:|---|
| PASS_MAX_DAYS | 99999 | Maximum password age in days |
| PASS_MIN_DAYS | 0 | Minimum days before a password can be changed |
| PASS_WARN_AGE | 7 | Days of warning before password expiration |

No active `PASS_MIN_LEN` setting was defined in this file.

These values provide defaults for account creation and certain account-management tools. They do not automatically update the password-aging settings of existing accounts.


### 9.2 PAM Password Quality Configuration

PAM (Pluggable Authentication Modules) provides a framework for Linux authentication and password-management operations.

The system authentication configuration was inspected for password-quality enforcement:

```bash
sudo grep -RniE 'pam_pwquality|retry=|minlen=|dcredit=|ucredit=|lcredit=|ocredit=' /etc/pam.d/system-auth /etc/security/pwquality.conf /etc/security/pwquality.conf.d/ 2>/dev/null
```

The inspection identified the following PAM configuration:

```text
pam_pwquality.so try_first_pass local_users_only retry=3
```

This confirms that the password-quality module is integrated into the authentication process for local users.

The configuration specifies up to three password-entry attempts. No explicit minimum-length or character-class requirements were found in the inspected configuration files.

Because no custom password-quality values were configured, the module's built-in defaults apply.

No PAM authentication settings were modified during this exercise.


### 9.3 Account Lockout Configuration

Account lockout controls can help protect Linux systems against repeated unsuccessful login attempts.

The PAM configuration was inspected for the `pam_faillock` module:

```bash id="t5j8k2"
sudo grep -Rni 'pam_faillock' /etc/pam.d/
```

No active `pam_faillock` entries were found in the PAM configuration files.

The `/etc/security/faillock.conf` file contained documented default settings, including:

| Setting | Documented Default | Purpose |
|---|---:|---|
| deny | 3 | Failed attempts before lockout |
| fail_interval | 900 seconds | Time window for failed attempts |
| unlock_time | 600 seconds | Lockout duration |

However, these values were not confirmed as an enforced account-lockout policy because the PAM configuration did not contain active `pam_faillock` entries.

The `faillock` utility was available for inspecting account failure records. The inspection returned no records for the accounts checked at that time.

No account-lockout configuration was changed during this exercise.


### 9.4 Existing Account Password and Expiration Policies

The `chage` utility was used to inspect password-aging and account-expiration settings for existing accounts.

The following commands were executed:

```bash
sudo chage -l automationuser
sudo chage -l labuser01
```

The inspection identified the following differences:

| Policy | automationuser | labuser01 |
|---|---|---|
| Minimum password age | 0 days | 1 day |
| Maximum password age | 99,999 days | 90 days |
| Password warning period | 7 days | 14 days |
| Password expiration | Never | February 10, 2027 |
| Account expiration | Never | December 31, 2027 |

The `labuser01` account had a more restrictive password-aging policy than `automationuser`.

The account expiration date was separate from the password expiration date. Password expiration requires a password change, while account expiration restricts account access after the specified date.

No existing account-aging settings were modified during this inspection.


### 9.5 Password Status Inspection

The `passwd -S` command was used to inspect password status information for selected local accounts.

```bash id="k3m8p2"
sudo passwd -S ADMIN_USER
sudo passwd -S automationuser
sudo passwd -S labuser01
sudo passwd -S admin
```

The results identified the following account states:

| Account | Password Status | Maximum Age | Warning Period |
|---|---|---:|---:|
| ADMIN_USER | PS | 99,999 days | 7 days |
| automationuser | LK | 99,999 days | 7 days |
| labuser01 | PS | 90 days | 14 days |
| admin | PS | 99,999 days | 7 days |

`PS` indicates that a password is set, while `LK` indicates that the password is locked.

These status codes describe password state and do not, by themselves, establish whether an account is fully enabled or disabled through every possible authentication method.

The administrator account displayed an unusual last password-change date of December 30, 1969. This finding should be investigated separately before making any account changes.

No passwords or account states were modified during this inspection.


## 10. Linux Auditing and Security Event Monitoring

Linux auditing provides a way to record and investigate security-related events on a system.

The Linux Audit subsystem uses the `auditd` service to collect and store audit events. Administrators can use these records to investigate file changes, privileged operations, authentication activity, and other monitored events.

The objective of this exercise was to inspect the audit subsystem, create a temporary file-monitoring rule, generate test events, and review the resulting audit records.

### 10.1 Audit Service and Kernel Status

The audit service and kernel audit status were inspected:

```bash id="h4m9q2"
sudo systemctl status auditd --no-pager
sudo auditctl -s
```

The inspection confirmed that:

- The `auditd` service was enabled and active.
- Kernel auditing was enabled.
- The audit failure mode was configured to log warnings.
- The audit backlog limit was 8,192 events.
- The number of lost events was zero.
- The current audit backlog was zero.

These results confirmed that the audit subsystem was operational before the file-monitoring exercise.


### 10.2 Inspecting Active and Persistent Audit Rules

The currently loaded audit rules were inspected:

```bash id="r5p2k8"
sudo auditctl -l
```

The command returned:

```text id="m8v3q1"
No rules
```

The persistent audit rules directory was also inspected:

```bash id="k2j7n4"
sudo ls -lh /etc/audit/rules.d/
sudo cat /etc/audit/rules.d/audit.rules
```

The existing rules file contained:

```text id="n6w4p9"
-D
-b 8192
--backlog_wait_time 60000
-f 1
```

These settings perform the following functions:

- `-D` removes previously loaded audit rules.
- `-b 8192` sets the audit backlog buffer limit.
- `--backlog_wait_time 60000` sets the kernel audit backlog wait time.
- `-f 1` configures the audit failure mode to log warnings.

No persistent file-monitoring rules were configured during the initial assessment.


### 10.3 Audit Log Configuration

The audit daemon configuration was inspected to identify the audit log location, log rotation settings, and disk-space protection policies.

The following command was used:

```bash id="w8m2q6"
sudo grep -nE '^(log_file|max_log_file|max_log_file_action|space_left|admin_space_left|disk_full_action|disk_error_action)' /etc/audit/auditd.conf
```

The inspection identified the following configuration:

| Setting | Value | Purpose |
|---|---|---|
| log_file | /var/log/audit/audit.log | Audit log storage location |
| max_log_file | 8 MB | Maximum audit log size |
| max_log_file_action | ROTATE | Rotates audit logs when the size limit is reached |
| space_left | 75 MB | Low disk-space warning threshold |
| space_left_action | SYSLOG | Sends a warning through syslog |
| admin_space_left | 50 MB | Administrative disk-space threshold |
| admin_space_left_action | SUSPEND | Suspends audit logging |
| disk_full_action | SUSPEND | Suspends auditing when the disk is full |
| disk_error_action | SUSPEND | Suspends auditing after a disk error |

The audit log directory was also inspected to verify that the log file existed and was protected by restrictive file permissions.

The configured suspension actions are important operational considerations because audit records may stop being collected when disk-space or storage errors occur.


### 10.4 Creating a Temporary File-Monitoring Rule

A dedicated directory and test file were created for the audit exercise:

```bash id="h2v7m9"
sudo mkdir -p /opt/audit-lab
sudo touch /opt/audit-lab/security-test.txt
sudo chown root:root /opt/audit-lab
sudo chmod 755 /opt/audit-lab
sudo chown root:root /opt/audit-lab/security-test.txt
sudo chmod 644 /opt/audit-lab/security-test.txt
```

A temporary audit watch was added to monitor file writes and attribute changes:

```bash id="r9k3w5"
sudo auditctl -w /opt/audit-lab/security-test.txt -p wa -k lab_file_monitor
```

The rule used these options:

- `-w` identifies the file to monitor.
- `-p wa` monitors write and attribute-change operations.
- `-k lab_file_monitor` assigns a searchable key to the rule.

The audit utility displayed a warning that the older watch-rule syntax is slower. The rule was nevertheless accepted and loaded successfully.

The rule was added at runtime and was not written to the persistent audit rules directory.


### 10.5 Generating and Investigating Audit Events

After loading the temporary audit rule, controlled file operations were performed to generate security events.

A text entry was appended to the test file:

```bash id="n4j7p2"
sudo sh -c 'echo "Audit monitoring test event" >> /opt/audit-lab/security-test.txt'
```

The file permissions were then changed:

```bash id="c8m2v5"
sudo chmod 640 /opt/audit-lab/security-test.txt
```

The audit records were searched using the rule's unique key:

```bash id="q7w3k9"
sudo ausearch -k lab_file_monitor -i
```

The search returned records for both operations:

- A successful `openat` system call associated with writing to the test file.
- A successful `fchmodat` system call associated with changing the file permissions to `640`.
- Configuration-change records showing that the temporary audit rule was added.

The records included information about the executable, file path, operation result, and user identities.

The `auid` field identifies the original login identity that initiated the activity, while the `uid` field identifies the effective user associated with the operation. In this exercise, privileged commands were executed through `sudo`, so the effective user was root while the original login identity remained associated with the audit event.


### 10.6 Removing the Temporary Audit Rule

After completing the monitoring exercise, the temporary audit rule was removed:

```bash id="h7m3q9"
sudo auditctl -W /opt/audit-lab/security-test.txt -p wa -k lab_file_monitor
```

The loaded rules were checked again:

```bash id="p2k8v4"
sudo auditctl -l
```

The command returned:

```text id="m5n9w3"
No rules
```

The audit search was repeated to confirm that historical records were retained after removing the rule:

```bash id="r4j6k2"
sudo ausearch -k lab_file_monitor -i
```

The historical results included a configuration-change event recording the removal of the temporary rule.

### 10.7 Test Resource Cleanup

The temporary test file and directory were removed:

```bash id="w9k2m6"
sudo rm -f /opt/audit-lab/security-test.txt
sudo rmdir /opt/audit-lab
```

The directory was checked afterward to confirm that the test resources had been removed.

The audit log files were retained for historical review.

No persistent custom audit rules were added during this exercise.


### 10.8 Final Audit Health Verification

The audit service and kernel status were checked after the test resources and temporary rule had been removed.

The following commands were executed:

```bash id="k8v3m5"
sudo systemctl is-active auditd
sudo auditctl -s
sudo auditctl -l
```

The final verification confirmed:

- The `auditd` service remained active.
- Kernel auditing remained enabled.
- The audit failure mode remained configured to log warnings.
- No audit events had been reported as lost.
- The current audit backlog was empty.
- No temporary custom audit rules remained loaded.

The historical audit records generated during the exercise remained available for investigation.

The audit monitoring exercise was completed without changing the persistent audit rules configuration.


## 11. Final Security Validation

After completing the security-hardening exercises, the system was checked to confirm that the primary security controls remained operational.

The final validation focused on SSH authentication, firewall configuration, SELinux enforcement, database network exposure, sudo permissions, and audit monitoring.

### 11.1 Security Service Status

The status of the primary security services was checked:

```bash id="x8k2m5"
sudo systemctl is-active sshd
sudo systemctl is-active firewalld
sudo systemctl is-active auditd
sudo systemctl is-active mariadb
```

The services returned an active state after the hardening exercises.

The checks confirmed that remote administration, firewall protection, audit monitoring, and the local database service remained operational.


### 11.2 SELinux and Firewall Verification

SELinux enforcement and the active firewall configuration were verified:

```bash id="p7k3m9"
getenforce
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --list-all
```

SELinux remained in `Enforcing` mode.

The active public firewall zone retained the required services:

- `ssh` for secure remote administration.
- `http` for the existing Apache web service.
- `dhcpv6-client` for network configuration.

The Cockpit firewall permission had been removed.

Firewall forwarding and masquerading remained disabled.

The active and permanent firewall configurations were checked and matched.

These results confirmed that the firewall continued to support required services while reducing unnecessary network exposure.


### 11.3 SSH and Database Network Verification

The effective SSH configuration was inspected to confirm the applied authentication restrictions:

```bash id="v3m9k2"
sudo sshd -T | grep -E 'permitrootlogin|pubkeyauthentication|passwordauthentication|kbdinteractiveauthentication|maxauthtries'
```

The effective configuration confirmed that:

- Direct root login was disabled.
- Public-key authentication was enabled.
- Password authentication was disabled.
- Keyboard-interactive authentication was disabled.
- The maximum authentication attempt count was three.

A fresh SSH public-key login was successful, while a password-only authentication test was rejected.

MariaDB network exposure was also verified:

```bash id="q6p2m8"
sudo ss -tulpn | grep ':3306'
```

The database listener was restricted to `127.0.0.1:3306`.

The local database remained accessible to applications on the server, while remote network connections to the MariaDB listener were no longer accepted through its listening interface.

These checks confirmed that SSH authentication and database network restrictions remained in effect.


### 11.4 Sudo and Audit Verification

The restricted sudo policy was inspected to confirm that the non-administrative account retained only its approved administrative command:

```bash id="m8q4v2"
sudo -l -U automationuser
```

The existing administrator's sudo privileges were also tested and remained functional.

The audit subsystem was checked after the temporary monitoring exercise:

```bash id="r2k7p5"
sudo systemctl is-active auditd
sudo auditctl -s
sudo auditctl -l
```

The final audit checks confirmed that:

- The audit service remained active.
- Kernel auditing remained enabled.
- No audit events had been reported as lost.
- The audit backlog was empty.
- No temporary custom audit rules remained loaded.

The final checks confirmed that restricted privilege management and audit monitoring remained operational.
## 12. Security Findings and Recommendations

The security assessment identified several areas that should receive additional attention in a production environment.

### 12.1 Password Aging Defaults

The system's default password aging configuration allows passwords to remain valid for up to 99,999 days.

**Recommendation:**

Review password aging defaults and establish an organization-approved password policy. Apply the policy consistently to newly created and existing accounts where appropriate.

### 12.2 Account Lockout Protection

The `pam_faillock` utility and configuration file were present, but no active PAM integration was identified during the assessment.

**Recommendation:**

Evaluate and configure account lockout protection through PAM. Test the policy carefully to reduce the risk of accidental account lockouts and denial-of-service conditions.

### 12.3 Administrator Password Aging Record

The administrator account displayed an unusual historical password-change date during the account status inspection.

**Recommendation:**

Investigate the account's password-aging metadata and confirm whether it reflects an expected system condition before making changes.

### 12.4 Persistent Audit Rules

The audit service was active, but no persistent event-monitoring rules were configured. The custom file-monitoring rule used in this lab was temporary and intentionally removed.

**Recommendation:**

Develop persistent audit rules for important security events, including changes to privileged configuration files, account administration, authentication activity, and critical system directories.

### 12.5 Audit Log Availability

The audit configuration uses suspension actions when disk space reaches certain critical conditions.

**Recommendation:**

Monitor audit log storage, configure appropriate alerting, and consider centralized log collection and retention to improve security-event visibility and investigation capabilities.

### 12.6 Database Network Access

MariaDB was successfully restricted to the local loopback interface.

**Recommendation:**

Keep database access local when applications run on the same server. If remote database access becomes necessary, implement appropriate network restrictions, authentication controls, and encrypted connections rather than exposing the database broadly.

### 12.7 Ongoing Security Maintenance

Security hardening requires continuous review rather than a one-time configuration exercise.

**Recommendation:**

Establish a recurring process for system updates, configuration reviews, access-control audits, backup validation, audit-log reviews, and security monitoring.

## 13. Lessons Learned

This lab provided practical experience applying enterprise Linux security controls on Rocky Linux 9.8.

Key lessons included:

1. **SSH hardening:** Configured public-key authentication, disabled password-based SSH authentication, and prevented direct root login.

2. **Firewall management:** Reviewed network exposure, removed unnecessary Cockpit firewall access, disabled forwarding, and preserved required services.

3. **Database security:** Restricted MariaDB to the local loopback interface to reduce unnecessary network exposure.

4. **SELinux administration:** Inspected security contexts, applied a temporary custom file-context mapping, restored default labels, and verified application access while SELinux remained enforcing.

5. **Privilege management:** Implemented a restricted sudo policy that allowed a non-administrative account to execute only an approved Apache status command.

6. **Password and account security:** Inspected password aging, PAM password-quality settings, account lockout configuration, and existing account expiration policies.

7. **Linux auditing:** Used `auditd`, `auditctl`, and `ausearch` to create a temporary file-monitoring rule, generate security events, investigate the results, and remove the temporary rule.

8. **Configuration management:** Practiced inspecting existing settings, backing up configuration files, validating changes, and verifying service behavior after applying security controls.

The lab reinforced the importance of layered security, least privilege, configuration validation, controlled testing, and ongoing monitoring.

## 14. Conclusion

The Enterprise Linux Security Hardening lab successfully demonstrated practical security administration on Rocky Linux 9.8.

The system's security posture was improved through SSH hardening, firewall restrictions, MariaDB network access controls, SELinux validation, and least-privilege sudo configuration.

Password policies, PAM settings, account aging, and audit configuration were also assessed to identify areas requiring additional attention.

The audit subsystem was tested using a temporary file-monitoring rule. Security events were successfully generated and investigated, and the temporary rule and test resources were removed after verification.

Final validation confirmed that critical services remained operational, SELinux remained in enforcing mode, required firewall services were preserved, and the applied security controls remained effective.

This project demonstrates practical experience with Linux system hardening, access control, network security, security auditing, troubleshooting, and technical documentation.

The lab provides a foundation for further enterprise Linux administration, infrastructure security, and DevOps engineering projects.
