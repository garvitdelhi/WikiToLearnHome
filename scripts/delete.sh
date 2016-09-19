#!/bin/bash
#delete the docker containers and the various valumes
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "delete.sh" ]] ; then
    echo "Wrong way to execute delete.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/$WTL_ENV.sh

if [[ $(docker ps -aq  --filter "name=$WTL_INSTANCE_NAME" | wc -l) -gt 0 ]] ; then
    wtl-event DELETING_INSTANCE $WTL_INSTANCE_NAME
    docker rm $(docker ps -aq  --filter "name=$WTL_INSTANCE_NAME")
fi
