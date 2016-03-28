#!/bin/bash
#delete the docker containers and the various valumes

cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
    echo "[wtl-delete] Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh

echo "[wtl-delete] wtl-destroy: Loading Environment"
. ./environments/$WTL_ENV.sh

echo "[wtl-delete] Removing dockers with prefix '$WTL_INSTANCE_NAME'"
docker rm $(docker ps -aq  --filter "name=$WTL_INSTANCE_NAME")
echo "[wtl-delete] Removing volumes with prefix '$WTL_INSTANCE_NAME'"
docker volume rm $(docker volume ls | grep $WTL_INSTANCE_NAME |  awk '{print $2}') 