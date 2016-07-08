#!/bin/bash
. ./load-libs.sh

if ! docker inspect ${WTL_INSTANCE_NAME}-ocg &> /dev/null ; then
    docker create -ti $MORE_ARGS -v ${WTL_VOLUME_DIR}wikitolearn-ocg:/tmp/ocg/ocg-output/ --hostname ocg \
        --link ${WTL_INSTANCE_NAME}-restbase:restbase \
        --link ${WTL_INSTANCE_NAME}-parsoid:parsoid \
        --name ${WTL_INSTANCE_NAME}-ocg $WTL_DOCKER_OCG
    wtl-log helpers/create/single-node.sh 0 CREATE_OCG "Creating docker ${WTL_INSTANCE_NAME}-ocg"
fi
