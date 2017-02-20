#!/bin/bash
set -e
cd "$HOME"

# setup ansible
echo "Setting up Ansible..."
sudo apt-get install python-dev
sudo pip install --upgrade pip
sudo pip install ansible docker-py toposort

# setup environment
echo "Setting up Environment..."
if [[ "${GIT_BRANCH}" == "production" ]];
then
  echo "export PROJECT_MODE=production" >> .circlerc
else
  echo "export PROJECT_MODE=staging" >> .circlerc
fi
echo "export PROJECT_BRANCH=$CIRCLE_BRANCH" >> .circlerc
echo "export PROJECT_VERSION=$CIRCLE_SHA1" >> .circlerc

# docker login
echo "Docker login..."
docker login --username ${QUAY_USER} --email ${QUAY_MAIL} --password ${QUAY_PASS} quay.io

echo "Done!"
