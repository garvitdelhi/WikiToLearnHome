#!/bin/bash

# run mamecached
docker ps | grep ${WTL_INSTANCE_NAME}-memcached &> /dev/null
if [[ $? -ne 0 ]] ; then
 docker ps -a | grep ${WTL_INSTANCE_NAME}-memcached &> /dev/null
 if [[ $? -eq 0 ]] ; then
  docker start ${WTL_INSTANCE_NAME}-memcached
 else
  docker run -ti $MORE_ARGS --hostname memcached.$WTL_DOMAIN_NAME --name ${WTL_INSTANCE_NAME}-memcached -d $WTL_DOCKER_MEMCACHED
 fi
fi

REF_WTL_MEMCACHE="docker:${WTL_INSTANCE_NAME}-memcached"
