#!/bin/bash
docker inspect ${WTL_INSTANCE_NAME}-parsoid &> /dev/null
if [[ $? -ne 0 ]] ; then
 echo "FATAL ERROR: MISSING PARSOID"
 exit 1
fi
docker start ${WTL_INSTANCE_NAME}-parsoid
docker start ${WTL_INSTANCE_NAME}-mathoid
docker start ${WTL_INSTANCE_NAME}-memcached
docker start ${WTL_INSTANCE_NAME}-mysql
docker start ${WTL_INSTANCE_NAME}-parsoid:parsoid
docker start ${WTL_INSTANCE_NAME}-websrv

