#!/bin/bash
set -e

# we clean up existing remote socket here.
# the socket gets created by ssh socket forwarding.
trap "rm -f /root/backup-server.sock" EXIT

#  run backup within snapshot over provided socket
export BORG_RSH="bash -c \"exec socat STDIO UNIX-CONNECT:/root/backup-server.sock\""
run-with-snapshot.sh \
    borg create --progress \
        "ssh://remote/backup/repos/$(hostname)::$(date +%Y-%m-%dT%H.%M)" \
        /mnt/root-snapshot/data
