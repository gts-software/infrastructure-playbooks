#!/bin/bash
set -e
cd "$HOME"

# setup environment
echo "Setting up Environment..."
if [[ "${CIRCLE_BRANCH}" == "production" ]];
then
  echo "export PROJECT_MODE=production" >> $BASH_ENV
else
  echo "export PROJECT_MODE=staging" >> $BASH_ENV
fi
echo "export PROJECT_BRANCH=$CIRCLE_BRANCH" >> $BASH_ENV
echo "export PROJECT_VERSION=$CIRCLE_SHA1" >> $BASH_ENV

# docker login
echo "Docker login..."
docker login --username ${QUAY_USER} --email ${QUAY_MAIL} --password ${QUAY_PASS} quay.io

echo "Done!"
