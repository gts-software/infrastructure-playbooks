#!/bin/bash
set -e
cd "$HOME"

# setup docker
echo "Setting up Docker..."
curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-1.13.1.tgz
sudo tar --strip-components=1 -xvzf docker-1.13.1.tgz -C /usr/local/bin
sudo container=yes docker daemon: { background: true }

# setup ansible
echo "Setting up Ansible..."
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
docker login --username ${QUAY_USER} --password ${QUAY_PASS} quay.io

echo "Done!"
