#!/bin/bash

# run ocg docker
docker ps | grep ${WTL_INSTANCE_NAME}-ocg &> /dev/null
if [[ $? -ne 0 ]] ; then
 docker ps -a | grep ${WTL_INSTANCE_NAME}-ocg &> /dev/null
 if [[ $? -eq 0 ]] ; then
  docker start ${WTL_INSTANCE_NAME}-ocg
 else
  langs="$(find $WTL_CONFIGS_DIR/secrets/ -name *wikitolearn.php -exec basename {} \; | sed 's/wikitolearn.php//g' | grep -v shared)"
  echo $langs
  docker run -ti $MORE_ARGS --hostname ocg.$WTL_DOMAIN_NAME -e langs="$langs" --name ${WTL_INSTANCE_NAME}-ocg -d $WTL_DOCKER_OCG
 fi
fi

REF_WTL_OCG="docker:${WTL_INSTANCE_NAME}-ocg"
