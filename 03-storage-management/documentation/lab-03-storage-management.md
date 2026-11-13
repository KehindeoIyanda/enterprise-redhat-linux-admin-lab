# Lab 03: Enterprise Linux Storage Management

## 1. Lab Overview

This lab demonstrates practical Linux storage administration using Logical Volume Manager (LVM) and the XFS filesystem on Rocky Linux 9.8.

A virtual disk image was created and attached as a loop device to provide an isolated storage environment. This approach allowed storage provisioning, filesystem creation, mounting, and expansion without modifying the laptop's physical storage partitions or production system volume group.

### Objectives

- Inspect block devices, partitions, filesystems, and mount points.
- Understand the relationship between physical volumes, volume groups, and logical volumes.
- Initialize an LVM physical volume.
- Create and manage an LVM volume group.
- Provision a logical volume.
- Create and mount an XFS filesystem.
- Perform basic filesystem read and write operations.
- Extend a logical volume and grow an XFS filesystem online.
- Understand persistent mount configuration using `/etc/fstab`.
- Validate filesystem configuration safely.

## 2. Lab Environment

| Component | Configuration |
|---|---|
| Operating system | Rocky Linux 9.8 |
| Storage management | LVM2 |
| Filesystem | XFS |
| Virtual storage device | 512 MiB disk image |
| Loop device | `/dev/loop0` |
| Physical volume | `/dev/loop0` |
| Volume group | `vg_lab` |
| Logical volume | `lv_data` |
| Mount point | `/mnt/lvm-lab` |
| Final logical volume size | 480 MiB |
| Final XFS reported size | 416 MiB |

## 3. Storage Architecture

The lab used a virtual disk image attached to a Linux loop device.

The storage hierarchy was:

```text
512 MiB Virtual Disk Image
          |
       /dev/loop0
          |
    LVM Physical Volume
          |
       vg_lab
     Volume Group
          |
       lv_data
    Logical Volume
       480 MiB
          |
      XFS Filesystem
          |
      /mnt/lvm-lab
```

### LVM Components

- **Physical Volume (PV):** The underlying block device initialized for LVM.
- **Volume Group (VG):** A storage pool created from one or more physical volumes.
- **Logical Volume (LV):** A virtual block device allocated from a volume group.
- **Filesystem:** The structure used by Linux to organize and access files.

## 4. Initial Storage Assessment

The following commands were used to inspect the existing storage configuration:

```bash
lsblk
df -hT
findmnt
sudo pvs
sudo vgs
sudo lvs
lsblk -f
```

### Baseline Findings

The system used an eMMC storage device with an existing LVM configuration.

The existing system volume group was named `rlm`, containing:

- Root logical volume.
- Swap logical volume.

The existing volume group had no free extents available for additional logical volumes.

The `/boot` filesystem was approximately 72% utilized during the initial assessment.

**Safety decision:** The existing system partitions and `rlm` volume group were not modified. An isolated virtual disk image was used for the exercises.

## 5. Virtual Disk Provisioning

A 512 MiB disk image was created inside the project directory.

```bash
mkdir -p 03-storage-management/images

fallocate -l 512M \
03-storage-management/images/lvm-lab-disk.img
```

The image was attached to an available loop device:

```bash
sudo losetup --find --show \
03-storage-management/images/lvm-lab-disk.img
```

The resulting device was:

```text
/dev/loop0
```

Verification:

```bash
sudo losetup -a
lsblk
```

The loop device provided a virtual block device for the LVM exercises without requiring additional physical storage hardware.

## 6. Physical Volume Initialization

The virtual block device was initialized as an LVM physical volume.

```bash
sudo pvcreate /dev/loop0
```

Verification:

```bash
sudo pvs
sudo pvdisplay /dev/loop0
```

The physical volume was successfully created with approximately 512 MiB of raw capacity.

## 7. Volume Group Creation

A volume group named `vg_lab` was created using the new physical volume.

```bash
sudo vgcreate vg_lab /dev/loop0
```

Verification:

```bash
sudo vgs
sudo vgdisplay vg_lab
sudo pvs
```

### Results

| Property | Result |
|---|---:|
| Volume group | `vg_lab` |
| Physical volumes | 1 |
| Logical volumes | 0 |
| Usable VG capacity | 508 MiB |
| Free capacity | 508 MiB |
| Physical extent size | 4 MiB |

The difference between the 512 MiB image size and 508 MiB usable volume group capacity reflects LVM metadata and extent alignment.

## 8. Logical Volume Provisioning

A 400 MiB logical volume named `lv_data` was created.

```bash
sudo lvcreate -L 400M -n lv_data vg_lab
```

Verification:

```bash
sudo lvs
sudo lvdisplay /dev/vg_lab/lv_data
sudo vgs
```

### Results

| Property | Result |
|---|---:|
| Logical volume | `lv_data` |
| Volume group | `vg_lab` |
| Initial LV size | 400 MiB |
| Allocated extents | 100 |
| Remaining VG capacity | 108 MiB |

Each physical extent was 4 MiB.

## 9. XFS Filesystem Creation

An XFS filesystem was created on the logical volume.

```bash
sudo mkfs.xfs /dev/vg_lab/lv_data
```

Verification:

```bash
sudo blkid /dev/vg_lab/lv_data
lsblk -f
```

The verification confirmed that the logical volume contained an XFS filesystem.

Filesystem UUIDs were intentionally excluded from this public report.

## 10. Filesystem Mounting

A mount point was created:

```bash
sudo mkdir -p /mnt/lvm-lab
```

The logical volume was mounted:

```bash
sudo mount /dev/vg_lab/lv_data /mnt/lvm-lab
```

Verification:

```bash
findmnt /mnt/lvm-lab
df -hT /mnt/lvm-lab
```

### Initial Mount Results

| Property | Result |
|---|---:|
| Filesystem | XFS |
| Logical volume | `vg_lab-lv_data` |
| Mount point | `/mnt/lvm-lab` |
| Reported filesystem size | 336 MiB |
| Available space | 314 MiB |

The filesystem was mounted with read/write access.

## 11. Filesystem Read and Write Testing

A test file was created:

```bash
sudo touch /mnt/lvm-lab/storage-test.txt
```

Content was written:

```bash
sudo sh -c \
'echo "XFS storage lab test" > /mnt/lvm-lab/storage-test.txt'
```

The file was read:

```bash
cat /mnt/lvm-lab/storage-test.txt
```

Directory contents were inspected:

```bash
ls -lh /mnt/lvm-lab
```

### Results

- File creation succeeded.
- Write operation succeeded.
- Read operation succeeded.
- File ownership and permissions were verified.

The test file was created with root ownership because the creation and write operations used `sudo`.

## 12. Logical Volume Expansion

Before extending the logical volume, available volume group capacity was checked.

```bash
sudo vgs
sudo lvs
df -hT /mnt/lvm-lab
```

The volume group had 108 MiB available.

The logical volume was extended by 80 MiB:

```bash
sudo lvextend -L +80M /dev/vg_lab/lv_data
```

### Results

| Property | Before | After |
|---|---:|---:|
| Logical volume | 400 MiB | 480 MiB |
| Allocated extents | 100 | 120 |
| Remaining VG capacity | 108 MiB | 28 MiB |

The logical volume was successfully increased from 400 MiB to 480 MiB.

**Important:** Extending an LVM logical volume does not automatically grow the filesystem when using this two-step procedure.

## 13. Online XFS Filesystem Expansion

The mounted XFS filesystem was expanded to use the additional logical volume capacity.

```bash
sudo xfs_growfs /mnt/lvm-lab
```

Verification:

```bash
df -hT /mnt/lvm-lab
sudo lvs
sudo vgs
```

### Final Results

| Property | Before | After |
|---|---:|---:|
| Logical volume | 400 MiB | 480 MiB |
| XFS reported size | 336 MiB | 416 MiB |
| Available filesystem space | 314 MiB | 393 MiB |
| VG free capacity | 108 MiB | 28 MiB |

The XFS filesystem was successfully expanded while mounted.

No unmount operation was required.

The `xfs_growfs` output confirmed that the data block count increased from 102,400 to 122,880.

## 14. Persistent Mount Configuration

The system's existing `/etc/fstab` configuration was inspected:

```bash
cat /etc/fstab
```

The file contained entries for:

- Root filesystem.
- `/boot`.
- EFI system partition.
- Swap.

A temporary copy was created for configuration testing:

```bash
sudo cp /etc/fstab /tmp/fstab-lab-test
```

A lab filesystem entry was added to the temporary copy using its UUID:

```text
UUID=<filesystem-uuid> /mnt/lvm-lab xfs defaults,nofail 0 0
```

The temporary configuration was validated:

```bash
sudo findmnt --verify --verbose \
--tab-file /tmp/fstab-lab-test
```

An initial validation detected a duplicate mount-point entry and an invalid UUID placeholder.

Both issues were corrected.

The final validation returned:

```text
Success, no errors or warnings detected.
```

**Important operational consideration:** The lab filesystem is hosted on a loop device backed by a disk image. The loop device must be attached before the filesystem can be mounted. A UUID entry alone does not establish this boot-time dependency.

The actual `/etc/fstab` was not modified.

## 15. Git Repository Protection

The virtual disk image was excluded from Git tracking using `.gitignore`.

```gitignore
# Local virtual disk images used for storage labs
03-storage-management/images/*.img
```

The exclusion was verified:

```bash
git check-ignore -v \
03-storage-management/images/lvm-lab-disk.img
```

The virtual disk image remains available locally for future exercises and is not intended for publication in the GitHub repository.

## 16. Key Skills Demonstrated

- Linux block-device administration.
- Disk and filesystem inspection.
- Loop device management.
- LVM physical volume provisioning.
- Volume group creation and management.
- Logical volume provisioning and expansion.
- XFS filesystem administration.
- Filesystem mounting and verification.
- Online filesystem expansion.
- Persistent mount configuration concepts.
- `/etc/fstab` validation and troubleshooting.
- Linux file ownership and permissions.
- Git repository hygiene and exclusion rules.

## 17. Troubleshooting and Lessons Learned

### Lesson 1: Volume group capacity differs from filesystem capacity

A filesystem can have free space even when its volume group has no unallocated extents. These are different layers of storage management.

### Lesson 2: Logical volume expansion and filesystem expansion are separate operations

The `lvextend` command increases block-device capacity. The `xfs_growfs` command expands the XFS filesystem to use that capacity.

### Lesson 3: XFS supports online growth

The filesystem was expanded while mounted, without interrupting access to the test file.

### Lesson 4: Validate `/etc/fstab` before applying changes

The temporary validation exercise demonstrated how duplicate mount points and invalid UUIDs can cause configuration problems.

### Lesson 5: Protect production storage

Using a loop-backed virtual disk isolated the exercises from the physical system disk and existing root volume group.

## 18. Conclusion

This lab provided hands-on experience with enterprise Linux storage administration using LVM2 and XFS on Rocky Linux 9.8.

A virtual disk was provisioned, initialized as an LVM physical volume, assigned to a volume group, and used to create a logical volume. An XFS filesystem was created, mounted, tested, and successfully expanded online.

The exercises also covered persistent mount configuration concepts, validation, troubleshooting, and Git repository protection.

The completed lab demonstrates practical foundational skills relevant to Linux System Administration, Red Hat Enterprise Linux operations, infrastructure support, and DevOps engineering.

---

**Environment:** Rocky Linux 9.8
**Storage technology:** LVM2 and XFS
**Project:** Enterprise Red Hat Linux Administration Lab
**Lab:** 03 — Enterprise Linux Storage Management
