#!/bin/bash

# mathoid running
docker ps | grep ${W2L_INSTANCE_NAME}-mathoid &> /dev/null
if [[ $? -ne 0 ]] ; then
 docker ps -a | grep ${W2L_INSTANCE_NAME}-mathoid &> /dev/null
 if [[ $? -eq 0 ]] ; then
  docker start ${W2L_INSTANCE_NAME}-mathoid
 else
  if [[ "$MATHOID_NUM_WORKERS" == "" ]] ; then
   export MATHOID_NUM_WORKERS=40
  fi
  docker run -ti $MORE_ARGS --hostname mathoid --name ${W2L_INSTANCE_NAME}-mathoid -e NUM_WORKERS=$MATHOID_NUM_WORKERS -d $W2L_DOCKER_MATHOID
 fi
fi

REF_W2L_MATHOID="docker:${W2L_INSTANCE_NAME}-mathoid"
