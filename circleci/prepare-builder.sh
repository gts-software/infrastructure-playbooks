#!/bin/bash

docker build -f builder.dockerfile -t quay.io/core_process/infrastructure-builder:latest ../
docker push quay.io/core_process/infrastructure-builder:latest
