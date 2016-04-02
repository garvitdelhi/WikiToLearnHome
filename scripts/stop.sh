#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "stop.sh" ]] ; then
    echo "Wrong way to execute stop.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

echo "wtl-stop: Loading Environment"
. $WTL_SCRIPTS/environments/$WTL_ENV.sh

echo "wtl-stop: Stopping Dockers with prefix '$WTL_INSTANCE_NAME'"
docker stop $(docker ps -aq  --filter "name=$WTL_INSTANCE_NAME")
