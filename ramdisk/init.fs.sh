#!/system/bin/sh

exec > /dev/kmsg 2>&1

export PATH=/res/asset:$PATH

cd /
mount -t f2fs \
      -o ro,nosuid,nodev,noatime,discard,background_gc=off \
      /dev/block/bootdevice/by-name/userdata /data || rm fstab.f2fs

umount /data
touch fstab.ready
