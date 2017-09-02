#!/bin/bash
set -e

# run up to 3 backups in parallel
export BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)
parallel --will-cite --keep-order --jobs 3 --joblog /backup/logs/joblog-$BACKUP_TIMESTAMP.log /backup/scripts/backup-object.sh {} '&>' /backup/logs/{}-$BACKUP_TIMESTAMP.log < /backup/config/objects.list

# cleanup logfiles
find /backup/logs/ -type f -mtime +14 -delete
