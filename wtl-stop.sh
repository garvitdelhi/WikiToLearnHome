#!/bin/bash
#Stop the docker containers named after $WTL_INSTANCE_NAME
 
cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
    echo "wtl-stop: Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh

echo "wtl-stop: Loading Environment"
. ./environments/$WTL_ENV.sh

echo "wtl-stop: Stopping Dockers with prefix '$WTL_INSTANCE_NAME'"
docker stop $(docker ps -aq  --filter "name=$WTL_INSTANCE_NAME")