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

if [[ $(docker volume ls -q --filter name="^$WTL_INSTANCE_NAME" | wc -l) -gt 0 ]] ; then
    wtl-event DELETING_VOLUMES $WTL_INSTANCE_NAME
    docker volume rm $(docker volume ls -q --filter name="^$WTL_INSTANCE_NAME")
fi
