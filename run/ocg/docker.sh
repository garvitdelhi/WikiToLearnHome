#!/bin/bash

# run ocg docker
docker ps | grep ${W2L_INSTANCE_NAME}-ocg &> /dev/null
if [[ $? -ne 0 ]] ; then
 docker ps -a | grep ${W2L_INSTANCE_NAME}-ocg &> /dev/null
 if [[ $? -eq 0 ]] ; then
  docker start ${W2L_INSTANCE_NAME}-ocg
 else
  langs="$(find $W2L_CONFIGS_DIR/secrets/ -name *wikitolearn.php -exec basename {} \; | sed 's/wikitolearn.php//g' | grep -v shared)"
  echo $langs
  docker run -ti $MORE_ARGS --hostname ocg.$W2L_DOMAIN_NAME -e langs="$langs" --name ${W2L_INSTANCE_NAME}-ocg -d $W2L_DOCKER_OCG
 fi
fi

REF_W2L_OCG="--link ${W2L_INSTANCE_NAME}-ocg:ocg"
