#!/bin/bash
set -e

# run up to 3 backups in parallel
NOW=$(date +%Y%m%d-%H%M%S)
parallel --will-cite --jobs 3 /backup/scripts/backup-object.sh {} '&>' /backup/logs/{}-$NOW.log < /backup/config/objects.list
