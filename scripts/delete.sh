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

echo "[wtl-delete] wtl-destroy: Loading Environment"
. $WTL_SCRIPTS/environments/$WTL_ENV.sh

echo "[wtl-delete] Removing dockers with prefix '$WTL_INSTANCE_NAME'"
docker rm $(docker ps -aq  --filter "name=$WTL_INSTANCE_NAME")
echo "[wtl-delete] Removing volumes with prefix '$WTL_INSTANCE_NAME'"
docker volume rm $(docker volume ls | grep $WTL_INSTANCE_NAME |  awk '{print $2}') 
