#!/bin/bash

# mathoid running
docker ps | grep ${WTL_INSTANCE_NAME}-mathoid &> /dev/null
if [[ $? -ne 0 ]] ; then
 docker ps -a | grep ${WTL_INSTANCE_NAME}-mathoid &> /dev/null
 if [[ $? -eq 0 ]] ; then
  docker start ${WTL_INSTANCE_NAME}-mathoid
 else
  if [[ "$MATHOID_NUM_WORKERS" == "" ]] ; then
   export MATHOID_NUM_WORKERS=40
  fi
  docker run -ti $MORE_ARGS --hostname mathoid --name ${WTL_INSTANCE_NAME}-mathoid -e NUM_WORKERS=$MATHOID_NUM_WORKERS -d $WTL_DOCKER_MATHOID
 fi
fi

REF_WTL_MATHOID="docker:${WTL_INSTANCE_NAME}-mathoid"
