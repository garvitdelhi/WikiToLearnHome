#!/bin/bash
#delete the docker containers and the various
#WIP 
cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

#. ./environments/$WTL_ENV.sh

docker rm $(docker ps -aq  --filter "name=$WTL_INSTANCE_NAME")

docker volume rm $(docker volume ls | grep $WTL_INSTANCE_NAME |  awk '{print $2}') 