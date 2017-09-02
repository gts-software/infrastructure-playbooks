#!/bin/bash
set -e

# run up to 3 backups in parallel
export BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)
if ! parallel --will-cite --keep-order --jobs 3 --joblog /backup/logs/joblog-$BACKUP_TIMESTAMP.log /backup/scripts/backup-object.sh {} '&>' /backup/logs/{}-$BACKUP_TIMESTAMP.log < /backup/config/objects.list;
then
  # collect number of backup jobs failed
  JOBS_FAILED_COUNT=$?

  # print warning
  echo "BACKUP FAILED: $JOBS_FAILED_COUNT backup(s) could not be completed!"
  echo

  # print logs
  for LOGFILE in `ls /backup/logs/*-$BACKUP_TIMESTAMP.log | sort`;
  do
    echo "################ `basename $LOGFILE` ################"
    echo "`cat $LOGFILE`"
    echo
  done
fi

# cleanup logfiles
find /backup/logs/ -type f -mtime +14 -delete
