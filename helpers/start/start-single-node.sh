#!/bin/bash
docker inspect ${WTL_INSTANCE_NAME}-parsoid &> /dev/null
if [[ $? -ne 0 ]] ; then
    cho "FATAL ERROR: MISSING PARSOID"
    exit 1
fi
docker start ${WTL_INSTANCE_NAME}-parsoid
if [[ $? -ne 0 ]] ; then
    echo "FATAL ERROR: MISSING PARSOID"
    exit 1
fi
docker start ${WTL_INSTANCE_NAME}-mathoid
if [[ $? -ne 0 ]] ; then
    echo "FATAL ERROR: MISSING MATHOID"
    exit 1
fi
docker start ${WTL_INSTANCE_NAME}-memcached
if [[ $? -ne 0 ]] ; then
    echo "FATAL ERROR: MISSING MEMCACHED"
    exit 1
fi
docker start ${WTL_INSTANCE_NAME}-mysql
if [[ $? -ne 0 ]] ; then
    echo "FATAL ERROR: MISSING MYSQL"
    exit 1
fi
docker start ${WTL_INSTANCE_NAME}-parsoid:parsoid
if [[ $? -ne 0 ]] ; then
    echo "FATAL ERROR: MISSING PARSOID"
    exit 1
fi
docker start ${WTL_INSTANCE_NAME}-websrv
if [[ $? -ne 0 ]] ; then
    echo "FATAL ERROR: MISSING WEBSRV"
    exit 1
fi

#TODO ocg?
