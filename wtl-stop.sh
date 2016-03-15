#!/bin/bash
#stop the docker containers named after
#WIP 
cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

#. ./environments/$WTL_ENV.sh

docker stop $(docker ps -aq  --filter "name=$WTL_INSTANCE_NAME")