#!/bin/bash
set -e

# run up to 3 backups in parallel and collect number of backup jobs failed
export BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)

JOBS_FAILED_COUNT="0"
parallel --will-cite --keep-order --jobs 3 --joblog /backup/logs/joblog-$BACKUP_TIMESTAMP.log /backup/scripts/backup-object.sh {} '&>' /backup/logs/{}-$BACKUP_TIMESTAMP.log < /backup/config/objects.list || JOBS_FAILED_COUNT="$?"

# validate result
if [ "$JOBS_FAILED_COUNT" != "0" ];
then
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
