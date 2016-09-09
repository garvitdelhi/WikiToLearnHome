#!/bin/bash
#delete the docker containers and the various valumes
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "delete-volumes.sh" ]] ; then
    echo "Wrong way to execute delete-volumes.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/$WTL_ENV.sh

if [[ $(docker volume ls | grep $WTL_INSTANCE_NAME |  awk '{print $2}' | wc -l) -gt 0 ]] ; then
    wtl-log scripts/delete-volumes.sh 4 DELETING_VOLUMES  "Removing volumes with prefix '$WTL_INSTANCE_NAME'"
    docker volume rm $(docker volume ls | grep $WTL_INSTANCE_NAME |  awk '{print $2}')
fi
