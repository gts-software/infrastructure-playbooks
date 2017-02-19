#!/bin/bash
set -e

PLAYBOOK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while getopts p:m:b:v: option
do
  case "${option}" in
    p)
      PLAYBOOK_DIR="$OPTARG"
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
      echo "Usage: $0 [-p playbook_dir] [-m project_mode] [-p project_branch] [-v project_version]"
      exit 1
      ;;
  esac
done

${PROJECT_MODE:='staging'}
${PROJECT_BRANCH:="`git rev-parse --abbrev-ref HEAD 2> /dev/null || echo 'unknown'`"}
${PROJECT_VERSION:="`git rev-parse --verify HEAD 2> /dev/null || echo 'unknown'`"}

ansible-playbook $PLAYBOOK_DIR/deploy-project.yml -e project_mode=$PROJECT_MODE -e project_branch=$PROJECT_BRANCH -e project_version=$PROJECT_VERSION -e @project.yml
