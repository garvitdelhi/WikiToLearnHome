#!/bin/bash

# parsoid running
docker ps | grep ${WTL_INSTANCE_NAME}-parsoid &> /dev/null
if [[ $? -ne 0 ]] ; then
 docker ps -a | grep ${WTL_INSTANCE_NAME}-parsoid &> /dev/null
 if [[ $? -eq 0 ]] ; then
  docker start ${WTL_INSTANCE_NAME}-parsoid
 else
  docker run -ti $MORE_ARGS --hostname parsoid --name ${WTL_INSTANCE_NAME}-parsoid -d $WTL_DOCKER_PARSOID
 fi
fi

REF_WTL_PARSOID="docker:${WTL_INSTANCE_NAME}-parsoid"
