#!/bin/bash

# get parameter
BACKUP_OBJECT="$1"

# read configuration
. /backup/config/vars.sh

# run rdiff-backup
export AWS_ACCESS_KEY_ID="$AWS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_KEY_SECRET"
duplicity --asynchronous-upload --no-encryption --full-if-older-than "$REMOTE_FULL_IF_OLDER_THAN" --exclude "/backup/repos/$BACKUP_OBJECT/rdiff-backup-data" "/backup/repos/$BACKUP_OBJECT" "$AWS_S3_URL/$BACKUP_OBJECT"
EXIT_CODE="$?"

# done!
exit $EXIT_CODE
