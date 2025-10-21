#!/bin/bash
logger "USB device detected – remounting and refreshing NFS"
echo "USB device detected – remounting and refreshing NFS"
# Small delay so the kernel detects the block device fully
sleep 3

MOUNT_POINT="/mnt/usbshare"

# Stop NFS temporarily to release handles
systemctl stop nfs-kernel-server 2>/dev/null

# Try to unmount even if 'busy'
if mountpoint -q "$MOUNT_POINT"; then
  fuser -km "$MOUNT_POINT" 2>/dev/null || true
  umount -lf "$MOUNT_POINT" 2>/dev/null || true
fi

# Mount everything from fstab (uses UUID)
mount -a

# Restart and refresh NFS
systemctl start nfs-kernel-server
exportfs -ra

logger "USB NFS remount + pod refresh complete"
echo "USB NFS remount"
showmount -e localhost
