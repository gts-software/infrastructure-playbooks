#!/bin/bash
set -e

TEMPLATE_URL="https://github.com/core-process/infrastructure-playbooks/archive/master.zip"

# check if pwd is empty
if [ "`ls -1`" ];
then
  echo "Error: the current directory is not empty!"
  exit 1
fi

# download and extract archive
TMP_FILE="`mktemp`"
curl -q -f -L -o "$TMP_FILE" "$TEMPLATE_URL"
unzip "$TMP_FILE"
rm "$TMP_FILE"

# move inventory template to the top
mv ./infrastructure-playbooks/templates/inventory/* .

# delete the rest
rm -r ./infrastructure-playbooks
