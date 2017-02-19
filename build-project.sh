#!/bin/bash
set -e

PLAYBOOK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while getopts p:s:m:b:v: option
do
  case "${option}" in
    p)
      PLAYBOOK_DIR="$OPTARG"
      ;;
    s)
      PROJECT_SOURCE="$OPTARG"
      ;;
    m)
      PROJECT_MODE="$OPTARG"
      ;;
    b)
      PROJECT_BRANCH="$OPTARG"
      ;;
    v)
      PROJECT_VERSION="$OPTARG"
      ;;
    \?)
      echo "Usage: $0 [-p playbook_dir] [-s project_source] [-m project_mode] [-p project_branch] [-v project_version]"
      exit 1
      ;;
  esac
done

${PROJECT_SOURCE:="`pwd`"}
${PROJECT_MODE:='staging'}
${PROJECT_BRANCH:="`git rev-parse --abbrev-ref HEAD 2> /dev/null || echo 'unknown'`"}
${PROJECT_VERSION:="`git rev-parse --verify HEAD 2> /dev/null || echo 'unknown'`"}

ansible-playbook $PLAYBOOK_DIR/build-project.yml -e project_source=$PROJECT_SOURCE -e project_mode=$PROJECT_MODE -e project_branch=$PROJECT_BRANCH -e project_version=$PROJECT_VERSION -e @project.yml
