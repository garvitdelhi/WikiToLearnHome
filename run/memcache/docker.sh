#!/bin/bash

# run mamecached
docker ps | grep ${W2L_INSTANCE_NAME}-memcached &> /dev/null
if [[ $? -ne 0 ]] ; then
 docker ps -a | grep ${W2L_INSTANCE_NAME}-memcached &> /dev/null
 if [[ $? -eq 0 ]] ; then
  docker start ${W2L_INSTANCE_NAME}-memcached
 else
  docker run -ti $MORE_ARGS --hostname memcached.$W2L_DOMAIN_NAME --name ${W2L_INSTANCE_NAME}-memcached -d $W2L_DOCKER_MEMCACHED
 fi
fi

REF_W2L_MEMCACHE="--link ${W2L_INSTANCE_NAME}-memcached:memcached"
