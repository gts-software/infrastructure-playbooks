#!/bin/bash
set -e

# run 3 backups in parallel
echo ">> INFO: backup objects in parallel"
parallel --will-cite --jobs 3 /backup/scripts/backup-object.sh {} < /backup/config/objects.list
