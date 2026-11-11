# Lab 01: Enterprise Linux System Inventory and Baseline Assessment

## 1. Lab Overview

**Project:** Enterprise Red Hat Linux Administration Lab
**Lab:** 01 - System Inventory and Baseline Assessment
**Operating System:** Rocky Linux 9.8
**Assessment Date:** November 10, 2026
**Status:** Completed

## 2. Objective

The objective of this lab was to perform an initial infrastructure assessment
of a Rocky Linux system.

The assessment examined operating system information, hardware resources,
storage configuration, logical volume management, network connectivity,
package management, running services, and basic security settings.

All inventory and baseline checks were performed using read-only commands.
No partitions, logical volumes, firewall rules, or system configurations
were modified.

## 3. Business Purpose

Enterprise Linux administrators need an accurate understanding of the
systems they manage before deploying applications, applying updates,
troubleshooting incidents, or implementing security controls.

This assessment establishes a baseline that can support:

- Infrastructure capacity planning
- System maintenance and patch management
- Security and compliance reviews
- Service availability monitoring
- Troubleshooting and incident response
- Future automation and configuration management

## 4. System Environment

| Component | Assessment Result |
|---|---|
| Operating system | Rocky Linux 9.8 |
| Hardware | HP Stream Laptop 14-ax0XX |
| Architecture | x86_64 |
| Processor | Intel Celeron N3060 |
| CPU cores | 2 |
| Logical CPUs | 2 |
| Installed memory | 3.5 GiB |
| Swap | 2.9 GiB |
| Primary storage | Approximately 29.1 GB eMMC |
| Root filesystem | XFS |
| Volume management | LVM |
| Network connection | Wireless |
| Init system | systemd |

## 5. CPU and Memory Assessment

The system has an Intel Celeron N3060 processor with two physical
cores and two logical CPUs.

Memory assessment:

- Total RAM: 3.5 GiB
- Available memory at assessment: approximately 2.5 GiB
- Swap capacity: 2.9 GiB
- Swap usage at assessment: 0 bytes

**Finding:** The system has limited hardware resources. Additional
services and monitoring components should be deployed selectively
to avoid unnecessary memory and CPU consumption.

## 6. Storage and Filesystem Assessment

The primary storage device is eMMC.

The system uses an EFI boot partition, a separate /boot partition,
and an LVM physical volume for its main operating system storage.

| Mount point | Filesystem | Size | Used | Available | Usage |
|---|---|---:|---:|---:|---:|
| / | XFS | 25 GB | 8.4 GB | 17 GB | 35% |
| /boot | XFS | 960 MB | 688 MB | 273 MB | 72% |
| /boot/efi | FAT32 | 599 MB | 7.7 MB | 592 MB | 2% |

### Logical Volume Management

The LVM configuration contains:

- Physical volume: /dev/mmcblk0p3
- Volume group: rlm
- Physical volumes in volume group: 1
- Logical volumes: 2
- Root logical volume: approximately 24.62 GiB
- Swap logical volume: approximately 2.91 GiB
- Unallocated volume group space: 0 GiB

**Findings:**

1. The root filesystem has approximately 17 GB of available space.
2. The /boot partition is 72% utilized and should be monitored during
   kernel updates.
3. The volume group has no unallocated extents available for additional
   logical volume allocation.
4. The root filesystem uses XFS.

No storage modifications were performed during this assessment.

## 7. Network Assessment

The system uses a wireless network interface managed by NetworkManager.

The following checks were successful:

| Test | Result |
|---|---|
| Network interface status | Connected |
| Default gateway connectivity | Successful |
| External IP connectivity | Successful |
| DNS hostname resolution | Successful |

The private IP address, Wi-Fi profile name, and other local network
identifiers have intentionally been excluded from this public report.

## 8. Package Management Assessment

The system uses DNF and RPM for package management.

| Component | Version / Result |
|---|---|
| DNF | 4.14.0 |
| RPM | 4.16.1.3 |
| Enabled repositories | 6 |
| Installed RPM packages | 1,237 |

### Enabled repositories

- Rocky Linux BaseOS
- Rocky Linux AppStream
- Rocky Linux Extras
- Extra Packages for Enterprise Linux (EPEL)
- EPEL Cisco OpenH264
- Visual Studio Code repository

**Finding:** Multiple software repositories are enabled. Repository
configuration and package sources should be reviewed as part of routine
software maintenance and security patch management.

## 9. Running Services Assessment

The system reported 38 running service units during the assessment.

Important services observed include:

| Service | Administrative Purpose |
|---|---|
| sshd | Remote administration |
| firewalld | Host firewall management |
| NetworkManager | Network configuration |
| chronyd | Time synchronization |
| auditd | Security auditing |
| rsyslog | System logging |
| crond | Scheduled task execution |
| httpd | Apache web server |
| mariadb | Database service |
| php-fpm | PHP application processing |
| airport-simulator | Existing application service |

**Finding:** The system hosts multiple application and infrastructure
services. Administrators should periodically review active services
and disable unnecessary services only after confirming they are not
required.

## 10. Security Baseline

| Security Component | Observed State |
|---|---|
| SELinux | Enforcing |
| firewalld | Running |
| Default systemd target | graphical.target |
| SSH service | Running |
| Audit service | Running |

**Assessment:** SELinux is actively enforcing mandatory access control
policies, and the firewalld service is running. These are positive
baseline observations.

The firewall's actual rules and exposed network ports were not audited
as part of this lab.

## 11. Commands Used

The following commands were used to collect system information:

### Operating system and hardware
- pwd
- hostnamectl
- lscpu
- free -h

### Storage and LVM
- df -hT
- lsblk -f
- findmnt /
- sudo pvs
- sudo vgs
- sudo lvs

### Network
- ip -br addr
- ip route
- nmcli device status
- ping -c 4 [gateway]
- ping -c 4 1.1.1.1
- getent hosts github.com

### Package management and services
- dnf --version
- sudo dnf repolist --enabled
- rpm -qa | wc -l
- systemctl --type=service --state=running --no-pager

### Security and system configuration
- getenforce
- sudo firewall-cmd --state
- systemctl get-default

## 12. Key Findings and Recommendations

| Finding | Recommendation |
|---|---|
| Limited RAM and CPU resources | Avoid unnecessary resource-intensive services |
| /boot is 72% utilized | Monitor available space before kernel updates |
| LVM volume group has no free extents | Consider storage capacity requirements before future expansion |
| 38 services are running | Review service requirements and resource consumption |
| Multiple repositories are enabled | Maintain trusted repository sources and review updates |
| SELinux is Enforcing | Preserve enforcement and investigate policy denials properly |
| firewalld is running | Review firewall rules and exposed ports in a future security lab |

## 13. Assessment Conclusion

The Rocky Linux system was successfully inventoried and assessed.

The operating system, hardware, memory, storage, network connectivity,
package management, running services, and basic security configuration
were examined.

The system has working network connectivity, an operational package
manager, active system services, SELinux enforcement, and a running
host firewall.

The primary infrastructure constraints are limited hardware resources,
increased /boot utilization, and the absence of unallocated LVM space.

This assessment provides a baseline for the next stages of the
Enterprise Red Hat Linux Administration Lab.

## 14. Security and Documentation Considerations

This report intentionally excludes:

- Machine IDs and boot IDs
- Filesystem UUIDs
- Private IP addresses
- Wi-Fi profile names and passwords
- User credentials and authentication secrets

Public infrastructure documentation should provide useful technical
details without exposing sensitive system or network information.
