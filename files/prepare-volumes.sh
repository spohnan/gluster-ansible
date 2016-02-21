#!/usr/bin/env bash

# Lists all block devices and skips the first two lines containing a column label and /dev/sda boot volume
DATA_VOLUMES=$(lsblk -d | awk '{ print $1 }' | grep -v "loop" | tail -n+3)

# Loop through each data volume and add a single partition with an XFS file system and mount
for v in $DATA_VOLUMES; do
  parted -s -- /dev/$v mklabel gpt
  parted -s -- /dev/$v mkpart primary ext4 2048s 100%
  sleep 2
  mkfs.xfs -i size=512 /dev/${v}1
  sleep 2
  mkdir -p /bricks/${v}
  echo "/dev/${v}1 /bricks/${v} xfs defaults 0 0" >> /etc/fstab
done

mount -a && mount