#!/bin/bash
set -e

TEMPLATE_URL="https://github.com/core-process/infrastructure-inventory-example/archive/master.zip"

# check if pwd is empty
if [ "`ls -1`" ];
then
  echo "Error: the current directory is not empty!"
  exit 1
fi

# download and extract template
TMP_FILE="`mktemp`"
curl -q -f -L -o "$TMP_FILE" "$TEMPLATE_URL"
unzip "$TMP_FILE"
rm "$TMP_FILE"

# move one level up
for d in `ls -1`
do
  mv "$d"/* . && rmdir "$d"
done