#!/bin/bash

# create snapshot
echo "> verify snapshot mount directory exists"
if ! mkdir -p --mode=0700 /mnt/root-snapshot; then
  exit 1
fi

echo "> verify snapshot directory is not mounted"
if mountpoint -q /mnt/root-snapshot; then
  exit 1
fi

echo "> verify the snapshot directory is empty"
if [ "$(ls -A /mnt/root-snapshot)" ]; then
  exit 1
fi

echo "> creating snapshot (using all available space)"
if ! lvcreate --extents 100%FREE --snapshot --name root-snapshot /dev/main/root; then
  exit 1
fi
sleep 1s

echo "> mounting snapshot read-only"
if ! mount -o ro /dev/main/root-snapshot /mnt/root-snapshot; then
  lvremove --force /dev/main/root-snapshot
  exit 1
fi
sleep 1s

echo "> verify snapshot directory is mounted"
if ! mountpoint -q /mnt/root-snapshot; then
  lvremove --force /dev/main/root-snapshot
  exit 1
fi

# clean up procedures
cleanup() {
  echo "> unmounting snapshot directory"
  umount /mnt/root-snapshot
  sleep 1s

  echo "> show snapshot status"
  lvdisplay /dev/main/root-snapshot

  echo "> removing snapshot"
  lvremove --force /dev/main/root-snapshot

  echo "> completed"
}

cleanup_on_trap() {
  trap '' INT TERM

  echo "> killing all processes accessing the snapshot"
  fuser -km /mnt/root-snapshot
  sleep 1s

  cleanup
  exit 111
}

trap cleanup_on_trap INT TERM

# run command
echo "> running command $1"
"$@"
EXIT_CODE=$?

# regular cleanup
cleanup
exit $EXIT_CODE
