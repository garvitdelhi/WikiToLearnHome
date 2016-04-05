#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "use-instance.sh" ]] ; then
    echo "Wrong way to execute use-instance.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh
. $WTL_SCRIPTS/environments/$WTL_ENV.sh

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
    echo "Missing key environment variabile WTL_INSTANCE_NAME in $WTL_ENV.sh"
    exit 1
fi

if docker inspect wikitolearn-haproxy &> /dev/null ; then
    echo "You have to un use the old instance first"
else
    echo "Bringing up \"${WTL_INSTANCE_NAME}\"..."

    CERTS_MOUNT=""
    if [[ -d certs/ ]] ; then
        CERTS_MOUNT=" -v $WTL_DIR/certs/:/certs/:ro "
    fi

    docker run -d --name wikitolearn-haproxy --restart=always \
        --label WTL_INSTANCE_NAME=${WTL_INSTANCE_NAME} \
        --label WTL_WORKING_DIR=$WTL_WORKING_DIR \
        -p 80:80 -p 443:443 \
        $CERTS_MOUNT \
        --link ${WTL_INSTANCE_NAME}-websrv \
        --link ${WTL_INSTANCE_NAME}-parsoid \
        --link ${WTL_INSTANCE_NAME}-restbase \
        $WTL_DOCKER_HAPROXY
fi
