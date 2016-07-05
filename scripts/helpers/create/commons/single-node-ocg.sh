#!/bin/bash

if ! docker inspect ${WTL_INSTANCE_NAME}-ocg &> /dev/null ; then
    docker create -ti $MORE_ARGS -v ${WTL_VOLUME_DIR}wikitolearn-ocg:/tmp/ocg/ocg-output/ --hostname ocg \
        --link ${WTL_INSTANCE_NAME}-restbase:restbase \
        --link ${WTL_INSTANCE_NAME}-parsoid:parsoid \
        --name ${WTL_INSTANCE_NAME}-ocg $WTL_DOCKER_OCG
    echo "[create/commons/single-node-ocg] Creating docker ${WTL_INSTANCE_NAME}-ocg"
fi
