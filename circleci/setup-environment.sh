#!/bin/bash
set -e

# environment variables
echo "Setting up environment..."
if [[ "${CIRCLE_BRANCH}" == "production" ]];
then
  echo "export PROJECT_MODE=production" >> "$BASH_ENV"
else
  echo "export PROJECT_MODE=staging" >> "$BASH_ENV"
fi
echo "export PROJECT_BRANCH=$CIRCLE_BRANCH" >> "$BASH_ENV"
echo "export PROJECT_VERSION=$CIRCLE_SHA1" >> "$BASH_ENV"

# docker login
echo "Perform docker login..."
docker login --username ${REGISTRY_USER} --password ${REGISTRY_PASS} ${REGISTRY_FQDN}

# ssh known_hosts
echo "Setup SSH known hosts..."
mkdir -p ~/.ssh
cat ~/project/.circleci/ssh_known_hosts >> ~/.ssh/known_hosts
