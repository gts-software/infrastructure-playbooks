#!/bin/bash
set -e

# retrieve parameter

HOST_NAME="$1"
HOST_IP_DNS="$2"
ROOT_PASSWORD_CURRENT="$3"
ROOT_PASSWORD_NEW="$4"

if [ -z "$ROOT_PASSWORD_NEW" ]
then
  ROOT_PASSWORD_NEW="$ROOT_PASSWORD_CURRENT"
fi

if [ "$ROOT_PASSWORD_NEW" == "auto" ]
then
  ROOT_PASSWORD_NEW="`< /dev/urandom tr -dc A-Za-z0-9 | head -c64; echo`"
fi

INVENTORY_DIRECTORY="`pwd`"

# validate parameter

if [ -z "$HOST_NAME" ] || [ -z "$HOST_IP_DNS" ] || [ -z "$ROOT_PASSWORD_CURRENT" ];
then
  echo "Usage: $0 <host name> <host ip or dns> <current root password> [<new root password>|auto]"
  echo "- If you provide a new root password, we will change the password on the host automatically."
  echo "- If you provide the keyword 'auto', we will generate a strong password automatically."
  exit 1
fi

echo "* running with the following parameters:"
echo "  - host name: $HOST_NAME"
echo "  - host ip or dns: $HOST_IP_DNS"
echo "  - current root password: $ROOT_PASSWORD_CURRENT"
echo "  - new root password: $ROOT_PASSWORD_NEW"
echo "  - inventory directory: $INVENTORY_DIRECTORY"

# validate inventory structure

echo "* validating inventory structure:"

if [ ! -f "$INVENTORY_DIRECTORY/hosts" ];
then
  echo "  - file hosts missing (error)"
  echo "* ABORTING!"
  exit 2
else
  echo "  - file hosts exists (ok)"
fi

if [ ! -d "$INVENTORY_DIRECTORY/host_vars" ];
then
  echo "  - creating empty host_vars directory (ok)"
  mkdir -p "$INVENTORY_DIRECTORY/host_vars"
else
  echo "  - directory host_vars exists (ok)"
fi

# validate if host is new

echo "* validating if host is new:"

if grep -q "^$HOST_NAME\$" "$INVENTORY_DIRECTORY/hosts"
then
  echo "  - host $HOST_NAME is defined in hosts file (error)"
  echo "* ABORTING!"
  exit 2
else
  echo "  - host $HOST_NAME is not defined in hosts file (ok)"
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
