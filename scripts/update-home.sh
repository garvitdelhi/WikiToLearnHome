#!/bin/bash
#This will git pull from origin the current branch

[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "update-home.sh" ]] ; then
    echo "Wrong way to execute update-home.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
git pull origin $BRANCH

