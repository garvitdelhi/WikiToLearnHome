#!/bin/bash

# parsoid running
docker ps | grep ${W2L_INSTANCE_NAME}-parsoid &> /dev/null
if [[ $? -ne 0 ]] ; then
 docker ps -a | grep ${W2L_INSTANCE_NAME}-parsoid &> /dev/null
 if [[ $? -eq 0 ]] ; then
  docker start ${W2L_INSTANCE_NAME}-parsoid
 else
  docker run -ti $MORE_ARGS --hostname parsoid --name ${W2L_INSTANCE_NAME}-parsoid -d $W2L_DOCKER_PARSOID
 fi
fi

REF_W2L_PARSOID="docker:${W2L_INSTANCE_NAME}-parsoid"
