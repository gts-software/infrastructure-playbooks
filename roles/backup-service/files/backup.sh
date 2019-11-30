#!/bin/bash
set -e

# run up to 3 backups in parallel and collect number of backup jobs failed
export BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)

JOBS_FAILED_COUNT="0"
jq -r '.objects | keys[]' /backup/config.json | \
  parallel \
    --will-cite --keep-order --jobs 3 \
    --joblog /backup/logs/joblog-$BACKUP_TIMESTAMP.log \
    /backup/scripts/backup-object.sh {} '&>' /backup/logs/{}-$BACKUP_TIMESTAMP.log \
      || JOBS_FAILED_COUNT="$?"

# validate result
if [ "$JOBS_FAILED_COUNT" != "0" ];
then
  # count skipped backups
  ((BACKUPS_SKIPPED_COUNT=0))
  while IFS=$'\t' read -r -a jobEntry
  do
   if [ "${jobEntry[6]}" == "99" ];
   then
     ((BACKUPS_SKIPPED_COUNT+=1))
   fi
  done < "/backup/logs/joblog-$BACKUP_TIMESTAMP.log"

  # calculate failed backups
  ((BACKUPS_FAILED_COUNT=$JOBS_FAILED_COUNT-$BACKUPS_SKIPPED_COUNT))

  # print logs in case we have failed backups
  if [ "$BACKUPS_FAILED_COUNT" != "0" ];
  then
    # print error
    echo "BACKUP FAILED: $BACKUPS_FAILED_COUNT backup(s) could not be completed!"
    echo "NOTE: $BACKUPS_SKIPPED_COUNT backup(s) skipped (blocked by parallel running backup processes)"
    echo

    # print logs
    for LOGFILE in `ls /backup/logs/*-$BACKUP_TIMESTAMP.log | sort`;
    do
      echo "################ `basename $LOGFILE` ################"
      echo "`cat $LOGFILE`"
      echo
    done
  fi
fi

# cleanup logfiles
find /backup/logs/ -type f -mtime +14 -delete
