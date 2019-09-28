#!/bin/bash

docker build -f builder.dockerfile -t docker.pkg.github.com/core-process/infrastructure-playbooks/infrastructure-builder:latest ../
docker push docker.pkg.github.com/core-process/infrastructure-playbooks/infrastructure-builder:latest
