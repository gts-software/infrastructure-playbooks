#!/bin/bash
set -e

OLD_DIR="`pwd`"
PLAYBOOK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while getopts p:m:b:v: option
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

: ${PROJECT_SOURCE:="`pwd`"}
: ${PROJECT_MODE:='staging'}
: ${PROJECT_BRANCH:="`cd "$PROJECT_SOURCE"; git rev-parse --abbrev-ref HEAD 2> /dev/null || echo 'unknown'`"}
: ${PROJECT_VERSION:="`cd "$PROJECT_SOURCE"; git rev-parse --verify HEAD 2> /dev/null || echo 'unknown'`"}

echo "Deploy:"
echo "* PLAYBOOK_DIR=$PLAYBOOK_DIR"
echo "* PROJECT_MODE=$PROJECT_MODE"
echo "* PROJECT_BRANCH=$PROJECT_BRANCH"
echo "* PROJECT_VERSION=$PROJECT_VERSION"

cd "$PLAYBOOK_DIR"
ansible-playbook $PLAYBOOK_DIR/deploy-project.yml -e project_mode=$PROJECT_MODE -e project_branch=$PROJECT_BRANCH -e project_version=$PROJECT_VERSION -e @project.yml

cd "$OLD_DIR"
echo "Done!"
