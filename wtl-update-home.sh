#!/bin/bash
#This will git pull from origin the current branch

cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
git pull origin $BRANCH

