#!/bin/bash

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# create snapshot
(
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

  echo "> running rdiff-backup server"
) 1>&2 </dev/null || exit 1

# run rdiff-backup server
rdiff-backup --server --restrict-read-only /mnt/root-snapshot
EXIT_CODE=$?
sleep 1s

# release snapshot
(
  echo "> unmounting snapshot directory"
	umount /mnt/root-snapshot
  sleep 1s

  echo "> show snapshot status"
	lvdisplay /dev/main/root-snapshot

  echo "> removing snapshot"
	lvremove --force /dev/main/root-snapshot

  echo "> completed"
) 1>&2 </dev/null

# return exit code of rdiff-backup
exit $EXIT_CODE
