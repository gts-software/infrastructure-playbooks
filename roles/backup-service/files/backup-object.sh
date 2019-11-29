#!/bin/bash
set -e

# get parameter
BACKUP_OBJECT="$1"

# acquire lock and run real backup procedure
echo ">> INFO: acquiring lock for backup of $BACKUP_OBJECT"

EXIT_CODE="0"
flock -x -E 99 -w 60 "/backup/locks/$BACKUP_OBJECT.lock" /backup/scripts/backup-object-task.sh "$BACKUP_OBJECT" || EXIT_CODE="$?"

if [ "$EXIT_CODE" != "0" ];
then
  if [ "$EXIT_CODE" == "99" ];
  then
    echo ">> WARNING: another backup task is still running (skipping)"
  else
    echo ">> ERROR: backup failed"
  fi
  exit "$EXIT_CODE"
fi
