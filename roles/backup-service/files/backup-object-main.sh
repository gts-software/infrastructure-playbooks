#!/bin/bash
set -e

# get parameter
BACKUP_OBJECT="$1"

echo ">> INFO: running backup for $BACKUP_OBJECT"

# make sure object directory exist
mkdir -p "/backup/repos/$BACKUP_OBJECT"

# run rdiff-backup
echo ">> INFO: running rdiff-backup for $BACKUP_OBJECT"
if ! /backup/scripts/backup-object-rdiff-backup.sh "$BACKUP_OBJECT";
then
  EXIT_CODE="$?"
  echo ">> ERROR: rdiff-backup failed for $BACKUP_OBJECT"
  exit $EXIT_CODE
fi

# run duplicity
echo ">> INFO: running duplicity for $BACKUP_OBJECT"
if ! /backup/scripts/backup-object-duplicity.sh "$BACKUP_OBJECT";
then
  EXIT_CODE="$?"
  echo ">> ERROR: duplicity failed for $BACKUP_OBJECT"
  exit $EXIT_CODE
fi

# done
echo ">> INFO: completed backup for $BACKUP_OBJECT"
