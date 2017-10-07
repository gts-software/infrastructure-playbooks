#!/bin/bash

docker build -t quay.io/core_process/infrastructure-builder:latest - < builder.dockerfile
docker push quay.io/core_process/infrastructure-builder:latest
