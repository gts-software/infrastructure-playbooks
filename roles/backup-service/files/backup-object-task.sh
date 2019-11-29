#!/bin/bash
set -e

# get parameter
BACKUP_OBJECT="$1"

# initialization
echo ">> INFO: running backup for $BACKUP_OBJECT"

if ! mkdir -p "/backup/repos/$BACKUP_OBJECT";
then
  exit 1
fi

rm -f /backup/socks/$BACKUP_OBJECT.sock

#### backup phase

# run borg create
echo ">> INFO: running 'borg create' for $BACKUP_OBJECT"

socat UNIX-LISTEN:/backup/socks/$BACKUP_OBJECT.sock,fork \
    "EXEC:borg serve --append-only --restrict-to-path /backup/repos/$BACKUP_OBJECT" &
SOCAT_PID=$!

if ! \
  ssh \
    -R /backup/socks/$BACKUP_OBJECT.sock:/root/backup-server.sock \
    root@TODO \
    backup-on-pull.sh \
      create \
      ssh://remote/backup/repos/$BACKUP_OBJECT::$(date +%Y-%m-%dT%H.%M) \
      /mnt/root-snapshot/data ;
then
  echo ">> ERROR: 'borg create' failed for $BACKUP_OBJECT"
  exit 2
fi

kill -INT $SOCAT_PID

# run borg prune
echo ">> INFO: running 'borg prune' for $BACKUP_OBJECT"
if ! \
  borg \
    prune --list \
    --keep-TODO \
    /backup/repos/$BACKUP_OBJECT ;
then
  echo ">> ERROR: 'borg prune' failed for $BACKUP_OBJECT"
  exit 3
fi

# run aws s3 sync
echo ">> INFO: running 'aws s3 sync' for $BACKUP_OBJECT"
if ! \
  AWS_ACCESS_KEY_ID=TODO \
  AWS_SECRET_ACCESS_KEY=TODO \
  borg \
    with-lock /backup/repos/$BACKUP_OBJECT \
    aws \
      s3 sync \
      /backup/repos/$BACKUP_OBJECT \
      s3://TODO/$BACKUP_OBJECT \
      --delete ;
then
  echo ">> ERROR: 'aws s3 sync' failed for $BACKUP_OBJECT"
  exit 4
fi

# done
echo ">> INFO: completed backup for $BACKUP_OBJECT"
exit 0
