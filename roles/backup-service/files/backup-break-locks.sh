#!/bin/bash

while pgrep -x borg > /dev/null;
do
    echo "> killing running borg processes"
    killall -9 borg
    sleep 5s
done

for BACKUP_OBJECT in $(jq -r '.objects | keys[]' /backup/config.json);
do
    echo "> breaking lock for $BACKUP_OBJECT"
    borg --verbose break-lock "/backup/repos/$BACKUP_OBJECT"
done
