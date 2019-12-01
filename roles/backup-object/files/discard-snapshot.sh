#!/bin/bash

if mountpoint -q /mnt/root-snapshot/;
then
    echo "> killing all processes accessing the snapshot"
    fuser -km /mnt/root-snapshot
    sleep 1s

    echo "> unmounting snapshot directory"
    umount /mnt/root-snapshot
    sleep 1s
else
    echo "> snapshot not mounted"
fi

if [ -e /dev/main/root-snapshot ];
then
    echo "> removing snapshot"
    lvremove --force /dev/main/root-snapshot
else
    echo "> snapshot not created"
fi

echo "> completed"
