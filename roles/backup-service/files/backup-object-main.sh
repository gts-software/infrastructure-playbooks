#!/bin/bash
set -e

# get parameter
BACKUP_OBJECT="$1"

# read configuration
. /backup/config/vars.sh

# make sure object directory exist
echo ">> INFO: running backup for $BACKUP_OBJECT"
if ! mkdir -p "/backup/repos/$BACKUP_OBJECT";
then
  exit 1
fi

#### backup phase

# run rdiff-backup
echo ">> INFO: running rdiff-backup for $BACKUP_OBJECT"
if ! /backup/scripts/backup-object-rdiff-backup.sh "$BACKUP_OBJECT";
then
  echo ">> ERROR: rdiff-backup failed for $BACKUP_OBJECT"
  exit 2
fi

# run duplicity
echo ">> INFO: running duplicity for $BACKUP_OBJECT"
if ! /backup/scripts/backup-object-duplicity.sh "$BACKUP_OBJECT";
then
  echo ">> ERROR: duplicity failed for $BACKUP_OBJECT"
  exit 3
fi

#### cleanup phase

EXIT_CODE="0"

# cleanup rdiff-backup
echo ">> INFO: cleanup rdiff-backup for $BACKUP_OBJECT"
if ! rdiff-backup --remove-older-than "$REMOVE_OLDER_THAN" --force "/backup/repos/$BACKUP_OBJECT";
then
  EXIT_CODE="4"
  echo ">> ERROR: cleanup rdiff-backup failed for $BACKUP_OBJECT"
fi

# cleanup duplicity
echo ">> INFO: cleanup duplicity for $BACKUP_OBJECT"

export AWS_ACCESS_KEY_ID="$AWS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_KEY_SECRET"

if ! duplicity remove-older-than "$REMOVE_OLDER_THAN" --force "$AWS_S3_URL/$BACKUP_OBJECT";
then
  EXIT_CODE="5"
  echo ">> ERROR: cleanup duplicity failed for $BACKUP_OBJECT"
fi

# done
echo ">> INFO: completed backup for $BACKUP_OBJECT"
exit "$EXIT_CODE"
