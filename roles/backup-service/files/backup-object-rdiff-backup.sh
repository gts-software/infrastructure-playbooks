#!/bin/bash

# get parameter
BACKUP_OBJECT="$1"

# run rdiff-backup
rdiff-backup --print-statistics --exclude-device-files --exclude-fifos --exclude-sockets --preserve-numerical-ids "root@$BACKUP_OBJECT::/mnt/root-snapshot" "/backup/repos/$BACKUP_OBJECT"
EXIT_CODE="$?"

# add some sleep to allow all output to be captured
sleep 10

# done!
exit $EXIT_CODE
