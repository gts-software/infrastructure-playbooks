#!/bin/bash

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# create snapshot
(
  if ! lvcreate --extents 100%FREE --snapshot --name root-snapshot /dev/main/root; then
  	exit 1
  fi

  if ! mount -o ro /dev/main/root-snapshot /mnt/root-snapshot; then
  	lvremove --force /dev/main/root-snapshot
  	exit 1
  fi
) 1>&2 </dev/null || exit 1

# run rdiff-backup server
rdiff-backup --server --restrict-read-only /mnt/root-snapshot
EXIT_CODE=$?

# release snapshot
(
	umount /mnt/root-snapshot
	lvdisplay /dev/main/root-snapshot
	lvremove --force /dev/main/root-snapshot
) 1>&2 </dev/null

# return exit code of rdiff-backup
exit $EXIT_CODE
