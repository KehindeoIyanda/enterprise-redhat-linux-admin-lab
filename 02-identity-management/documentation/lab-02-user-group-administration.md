# Lab 2: Enterprise Linux User and Group Administration

## 1. Lab Overview

This lab demonstrates Linux user and group administration on a Rocky Linux 9.8 system. The exercises cover account creation, password management, group membership, account expiration, login verification, file ownership, permissions, and collaborative access control.

**Operating System:** Rocky Linux 9.8 (Blue Onyx)

**Lab Environment:** Enterprise Red Hat Linux Administration Lab

**Primary Objective:** Practice enterprise Linux identity management and implement controlled access to shared administrative resources.

## 2. Learning Objectives

- Inspect Linux users, groups, UIDs, and GIDs.
- Understand `/etc/passwd`, `/etc/group`, `/etc/shadow`, and `/etc/gshadow`.
- Create and manage Linux user accounts.
- Configure password aging and account expiration.
- Lock and unlock user accounts.
- Manage primary and supplementary group memberships.
- Verify user login environments.
- Configure file ownership and permissions.
- Implement SetGID directory inheritance.
- Understand umask and shared-file permissions.
- Test group-based access control.

## 3. Existing Account and Privilege Assessment

Inspected the current administrative account:

```bash
id
groups
sudo -l
```

Findings:

- Administrative account: `kehinde`
- UID: `1000`
- Primary group: `kehinde`
- Supplementary administrative group: `wheel`
- Sudo access: Full administrative privileges

Verified the wheel group:

```bash
getent group wheel
```

## 4. Linux Account Database Inspection

Inspected account and group records:

```bash
grep '^kehinde:' /etc/passwd
grep '^wheel:' /etc/group
ls -l /etc/shadow
ls -l /etc/gshadow
```

Key findings:

- `/etc/passwd` contains user account information.
- `/etc/group` contains group account information.
- `/etc/shadow` stores protected password authentication data.
- `/etc/gshadow` stores protected group authentication information.

The shadow files were root-owned with restrictive permissions.

No password hashes or authentication secrets were included in this report.

## 5. User and Group Administration

### 5.1 Existing Group Inspection

Verified the existing `linuxadmins` group:

```bash
getent group linuxadmins
```

The group existed with GID `1002`.

Created a supplementary group:

```bash
sudo groupadd developers
getent group developers
```

The new group received GID `1003`.

### 5.2 Create the First Test Account

Created `labuser01` with a home directory, primary group, and Bash login shell:

```bash
sudo useradd -m -g linuxadmins -s /bin/bash labuser01
```

Verified the account:

```bash
id labuser01
getent passwd labuser01
ls -ld /home/labuser01
```

Results:

- Username: `labuser01`
- UID: `1002`
- Primary group: `linuxadmins`
- GID: `1002`
- Home directory: `/home/labuser01`
- Login shell: `/bin/bash`

### 5.3 Password Management

Configured the account password:

```bash
sudo passwd labuser01
```

Verified password status:

```bash
sudo passwd -S labuser01
```

The account initially showed `PS`, indicating that a password was set.

### 5.4 Password Aging Policy

Configured password aging:

```bash
sudo chage -m 1 -M 90 -W 14 labuser01
```

Verified:

```bash
sudo chage -l labuser01
```

Configured policy:

| Setting | Value |
|---|---|
| Minimum password age | 1 day |
| Maximum password age | 90 days |
| Password warning period | 14 days |
| Password expiration | February 10, 2027 |

### 5.5 Account Locking and Unlocking

Locked the test account:

```bash
sudo usermod -L labuser01
sudo passwd -S labuser01
```

The account status changed to `LK` (password locked).

Unlocked the account:

```bash
sudo usermod -U labuser01
sudo passwd -S labuser01
```

The status returned to `PS` (password set).

**Security note:** Password locking does not necessarily terminate active sessions or disable other authentication methods, such as SSH public-key authentication.

### 5.6 Supplementary Group Membership

Added `labuser01` to the `developers` group:

```bash
sudo usermod -aG developers labuser01
```

Verified:

```bash
id labuser01
groups labuser01
```

Removed the supplementary group membership:

```bash
sudo gpasswd -d labuser01 developers
```

Verified that the user remained in `linuxadmins` and that `developers` still existed.

**Key distinction:**

- `-g` changes the primary group.
- `-aG` appends supplementary group membership.
- `-G` replaces the supplementary group list when used without `-a`.

### 5.7 Account Expiration

Configured account expiration:

```bash
sudo chage -E 2027-12-31 labuser01
```

Verified:

```bash
sudo chage -l labuser01
```

Account expiration was configured for December 31, 2027.

Password expiration and account expiration are separate controls.

## 6. Login Environment Verification

Authenticated as the test user:

```bash
su - labuser01
```

Executed:

```bash
whoami
pwd
id
```

Results:

- User identity: `labuser01`
- Working directory: `/home/labuser01`
- UID: `1002`
- Primary group: `linuxadmins`

The login shell and home directory were verified successfully.

## 7. Linux File Ownership and Permissions

### 7.1 Create a Shared Administrative Directory

Created a dedicated directory:

```bash
sudo mkdir -p /opt/identity-lab
sudo chown root:linuxadmins /opt/identity-lab
sudo chmod 2770 /opt/identity-lab
```

Verified:

```bash
ls -ld /opt/identity-lab
```

Result:

```text
drwxrws---. root linuxadmins /opt/identity-lab
```

Permission interpretation:

- Owner: Full access.
- Group: Full access.
- Others: No access.
- SetGID: New entries inherit the directory's group ownership.

### 7.2 Test Group-Based Access

Authenticated as `labuser01` and created a file:

```bash
touch /opt/identity-lab/access-test.txt
ls -l /opt/identity-lab/
```

The file was owned by `labuser01` and assigned to `linuxadmins`.

Tested access as a non-member:

```bash
sudo -u nobody ls /opt/identity-lab
```

The operation returned `Permission denied`, confirming the directory's access restrictions.

## 8. Umask and Shared-File Permissions

Inspected the default umask:

```bash
umask
```

Initial result:

```text
0022
```

Temporarily changed the umask:

```bash
umask 0002
```

Created a shared file:

```bash
touch /opt/identity-lab/shared-file.txt
ls -l /opt/identity-lab/shared-file.txt
```

Resulting file permissions:

```text
-rw-rw-r--.
```

This demonstrated how umask affects permissions on newly created files.

| Umask | Resulting regular file permissions |
|---|---|
| 0022 | 644 |
| 0002 | 664 |

The umask change applied only to the current shell session.

## 9. Multi-User Collaboration

Created a second test account:

```bash
sudo useradd -m -g linuxadmins -s /bin/bash labuser02
sudo passwd labuser02
```

Verified:

```bash
id labuser02
getent passwd labuser02
```

Results:

- Username: `labuser02`
- UID: `1003`
- Primary group: `linuxadmins`
- GID: `1002`

Authenticated as `labuser02` and modified the shared file:

```bash
echo "Updated by labuser02 - Linux group collaboration test" >> /opt/identity-lab/shared-file.txt
cat /opt/identity-lab/shared-file.txt
```

The operation succeeded.

Created a second user's file:

```bash
touch /opt/identity-lab/labuser02-file.txt
ls -l /opt/identity-lab/
```

The file was owned by `labuser02` and inherited the `linuxadmins` group.

This verified multi-user collaboration through shared group ownership and group-write permissions.

## 10. Final Verification

Verified both test accounts:

```bash
id labuser01
id labuser02
sudo chage -l labuser01
sudo passwd -S labuser01
sudo passwd -S labuser02
```

Final account summary:

| Account | UID | Primary Group | Password Status |
|---|---:|---|---|
| labuser01 | 1002 | linuxadmins | PS |
| labuser02 | 1003 | linuxadmins | PS |

Both test accounts were active and retained their configured password settings at the end of the exercises.

## 11. Security Findings and Best Practices

The exercises demonstrated several important enterprise Linux security principles:

1. **Least privilege:** Users should receive only the permissions required for their responsibilities.
2. **Group-based access control:** Shared group ownership simplifies access management for teams.
3. **Password aging:** Password lifecycle policies can be configured with `chage`.
4. **Account lifecycle management:** Administrators can lock, unlock, and expire accounts.
5. **Protected authentication data:** Shadow files require restrictive access permissions.
6. **SetGID inheritance:** Shared directories can automatically assign a common group to new files.
7. **Umask management:** Default permissions should align with collaboration and security requirements.
8. **Access verification:** Permissions should be tested using both authorized and unauthorized accounts.

## 12. Challenges and Lessons Learned

- Distinguished primary group membership from supplementary group membership.
- Learned why `getent group` may not display users whose group is their primary group.
- Verified that password locking does not necessarily disable all authentication methods.
- Demonstrated that sudo privileges do not automatically grant ordinary directory access.
- Confirmed that SetGID controls group inheritance but does not automatically grant group-write permission.
- Demonstrated how umask affects newly created file permissions.
- Tested shared-file access using two separate user accounts.

## 13. Conclusion

This lab provided practical experience with enterprise Linux identity and access management on Rocky Linux 9.8.

The exercises covered user lifecycle management, group administration, password policies, account expiration, file ownership, permissions, SetGID inheritance, and multi-user collaboration.

These skills form a foundation for managing Linux accounts and securing shared resources in enterprise environments.

**Lab Status:** Completed

**Next Lab:** Enterprise Linux Storage Management
