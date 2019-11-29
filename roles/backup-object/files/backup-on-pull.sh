#!/bin/bash
set -e

# we clean up existing remote socket here.
# the socket gets created by ssh socket forwarding.
trap "rm -f /root/backup-server.sock" EXIT

# 
BORG_RSH="'bash -c \"exec socat STDIO UNIX-CONNECT:/root/backup-server.sock\"'"
run-with-snapshot.sh borg create -p ssh://remote/
