#!/bin/bash
set -e

# prepare for cron environment
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# run up to 3 backups in parallel
BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)

jq -r '.objects | keys[]' /backup/config.json | \
  parallel \
    --will-cite --keep-order --jobs 3 \
    --joblog /backup/logs/joblog-$BACKUP_TIMESTAMP.log \
    /backup/scripts/backup-object.sh {} '&>' /backup/logs/{}-$BACKUP_TIMESTAMP.log

# cleanup logfiles
find /backup/logs/ -type f -mtime +14 -delete
