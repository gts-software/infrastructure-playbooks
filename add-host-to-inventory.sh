#!/bin/bash
set -e

HOST_NAME="$1"
HOST_IP_DNS="$2"
ROOT_PASSWORD_CURRENT="$3"
ROOT_PASSWORD_NEW="`< /dev/urandom tr -dc A-Za-z0-9 | head -c64; echo`"
INVENTORY_DIRECTORY="`pwd`"

if [ -z "$HOST_NAME" ] || [ -z "$HOST_IP_DNS" ] || [ -z "$ROOT_PASSWORD_CURRENT" ];
then
  echo "Usage: $0 <host name> <host ip or dns> <current root password>"
  exit 1
fi

echo "* running with the following parameters:"
echo "  - host name: $HOST_NAME"
echo "  - host ip or dns: $HOST_IP_DNS"
echo "  - current root password: $ROOT_PASSWORD_CURRENT"
echo "  - new root password: $ROOT_PASSWORD_NEW"
echo "  - inventory directory: $INVENTORY_DIRECTORY"

# create basic structure of inventory directory if required

echo "* validating inventory directory:"

if [ ! -f "$INVENTORY_DIRECTORY/ansible.cfg" ];
then
  echo "  - creating ansible.cfg file"
  echo -e "[defaults]\ninventory = hosts" > "$INVENTORY_DIRECTORY/ansible.cfg"
else
  echo "  - file ansible.cfg exists"
fi

if [ ! -f "$INVENTORY_DIRECTORY/hosts" ];
then
  echo "  - creating empty hosts file"
  touch "$INVENTORY_DIRECTORY/hosts"
else
  echo "  - file hosts exists"
fi

if [ ! -d "$INVENTORY_DIRECTORY/host_vars" ];
then
  echo "  - creating empty host_vars directory"
  mkdir -p "$INVENTORY_DIRECTORY/host_vars"
else
  echo "  - directory host_vars exists"
fi

if [ ! -d "$INVENTORY_DIRECTORY/group_vars" ];
then
  echo "  - creating empty group_vars directory"
  mkdir -p "$INVENTORY_DIRECTORY/group_vars"
else
  echo "  - directory group_vars exists"
fi

# validate if group_vars/all.yml is defined already

echo "* validating if group_vars is populated:"

if [ ! -f "$INVENTORY_DIRECTORY/group_vars/all.yml" ];
then
  echo "  - creating group_vars/all.yml file"
  echo -e "# base\nbase_name_domain: example.local" > "$INVENTORY_DIRECTORY/group_vars/all.yml"
else
  echo "  - file group_vars/all.yml exists"
fi

# validate if host is not defined already

echo "* validating if host is not defined already:"

if grep -q "^$HOST_NAME\$" "$INVENTORY_DIRECTORY/hosts"
then
  echo "  - host $HOST_NAME is defined in hosts file already (error)"
  echo "* ABORTING!"
  exit 2
else
  echo "  - host $HOST_NAME is is not defined in hosts file (ok)"
fi

if [ -e "$INVENTORY_DIRECTORY/host_vars/$HOST_NAME" ] || [ -e "$INVENTORY_DIRECTORY/host_vars/$HOST_NAME.yml" ];
then
  echo "  - file or directory containing variables for $HOST_NAME exists already (error)"
  echo "* ABORTING!"
  exit 2
else
  echo "  - file or directory containing variables for $HOST_NAME does not exist (ok)"
fi

# add host to inventory

echo "* adding host to inventory:"

echo -e "$HOST_NAME\n$(cat "$INVENTORY_DIRECTORY/hosts")" > "$INVENTORY_DIRECTORY/hosts"
echo "  - added $HOST_NAME to hosts file"

echo -e "# ansible\nansible_host: $HOST_IP_DNS\nansible_user: root\nansible_password: $ROOT_PASSWORD_NEW\n\n# base\nbase_name_host: $HOST_NAME" > "$INVENTORY_DIRECTORY/host_vars/$HOST_NAME.yml"
echo "  - added host_vars/$HOST_NAME.yml file"

# update password on host
echo "* updating password on host:"
echo "root:$ROOT_PASSWORD_NEW" | sshpass -p "$ROOT_PASSWORD_CURRENT" ssh "root@$HOST_IP_DNS" chpasswd
echo "DONE!"
