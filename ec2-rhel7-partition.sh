#!/bin/bash -xe
# Script for partitioning a RHEL7 instance volume in AWS.

# Identify the volume to be modified
if lsblk /dev/xvda | grep -q "/"
  then
    vol="/dev/xvdf"
  else
    vol="/dev/xvda"
fi

# Change UUID
xfs_admin -U generate $vol'2'

# Mount
mount $vol'2' /mnt

# Backup
rsync -aAHXv --exclude={"/mnt/dev/*","/mnt/proc/*","/mnt/sys/*","/mnt/tmp/*","/mnt/var/tmp/*","/mnt/run/*"} /mnt/ /data

# Unmount
umount $vol'2'

# Partition
echo "Old partition table"
gdisk -l $vol

echo "Creating new partition table"
sgdisk --delete=2 $vol
sgdisk -n 0:0:+6G -t 2:0700 $vol
sgdisk -n 0:0:+4G -t 3:8200 $vol
sgdisk -n 0:0:+2G -t 4:0700 $vol
sgdisk -n 0:0:+1G -t 5:0700 $vol
sgdisk -n 0:0:+4G -t 6:0700 $vol
sgdisk -n 0:0:+4G -t 7:0700 $vol
sgdisk -n 0:0:+1G -t 8:0700 $vol
sgdisk -n 0:0:+3G -t 9:0700 $vol
sgdisk -n 0:0:+3G -t 10:0700 $vol

echo "New partition table"
gdisk -l $vol

# Format partitions
# Additional options must be specified due to xfsprogs changes
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/7.3_Release_Notes/new_features_file_systems.html#idp8454480
for i in 2 4 5 6 7 8 9 10
do
  mkfs.xfs -m crc=0 -n ftype=0 -f $vol$i
done

mkswap $vol'3'

# Restore files from backup
mount $vol'2' /mnt
rsync -aAHXv /data/ /mnt

# Update fstab
printf '/dev/xvda3 swap swap defaults 0 0\n' >> /mnt/etc/fstab
printf '/dev/xvda4 /opt xfs defaults 0 0\n' >> /mnt/etc/fstab
printf '/dev/xvda5 /home xfs defaults,nodev 0 0\n' >> /mnt/etc/fstab
printf '/dev/xvda6 /var xfs defaults 0 0\n' >> /mnt/etc/fstab
printf '/dev/xvda7 /var/log xfs defaults 0 0\n' >> /mnt/etc/fstab
printf '/dev/xvda8 /var/log/audit xfs defaults,context="system_u:object_r:auditd_log_t:s0" 0 0\n' >> /mnt/etc/fstab
printf '/dev/xvda9 /tmp xfs defaults,nodev,noexec,nosuid 0 0\n' >> /mnt/etc/fstab
printf '/dev/xvda10 /var/tmp xfs defaults,nodev,noexec,nosuid 0 0\n' >> /mnt/etc/fstab

# Clear /var/log/messages. This helps with troubleshooting in dev.
>/mnt/var/log/messages

umount $vol'2'

mount $vol'4' /mnt
rsync -aAXv /data/opt/ /mnt
umount $vol'4'

mount $vol'5' /mnt
rsync -aAXv /data/home/ /mnt
umount $vol'5'

mount $vol'6' /mnt
rsync -aAHXv /data/var/ /mnt
umount $vol'6'

mount $vol'7' /mnt
rsync -aAXv /data/var/log/ /mnt
umount $vol'7'

# Restore UUID
xfs_admin -U 379de64d-ea11-4f5b-ae6a-0aa50ff7b24d $vol'2'

if [ $vol = "/dev/xvda" ]
  then
    printf "** Partitioning Automation Script Completed! **\nStop this instance, detach the volume from the other instance, and restart this instance.\n** Create an AMI from this instance **\n"
  else
    printf "Partitioning procedure completed.\nStop this instance, detach the volume from the other instance and reattach it to its original instance with device name /dev/sda1.\n**Create an AMI from that other instance (NOT this instance)**\n"
fi