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
    wtl-log scripts/use-instance.sh 4 USE_INSTANCE_MISSING_INSTANCE_NAME "Missing key environment variabile WTL_INSTANCE_NAME in $WTL_ENV.sh"
    exit 1
fi

if docker inspect wikitolearn-haproxy &> /dev/null ; then
    wtl-log scripts/use-instance.sh 4 USE_INSTANCE_STOP_OLD "You have to un use the old instance first"
else
    wtl-log scripts/use-instance.sh 7 USE_INSTANCE_START "Bringing up \"${WTL_INSTANCE_NAME}\"..."
    docker create --name wikitolearn-haproxy --restart=always \
        --label WTL_INSTANCE_NAME=${WTL_INSTANCE_NAME} \
        --label WTL_WORKING_DIR=$WTL_WORKING_DIR \
        -p 80:80 -p 443:443 \
        --link ${WTL_INSTANCE_NAME}-websrv \
        --link ${WTL_INSTANCE_NAME}-parsoid \
        --link ${WTL_INSTANCE_NAME}-restbase \
        $WTL_DOCKER_HAPROXY
    docker cp ${WTL_CERTS}/wikitolearn.crt wikitolearn-haproxy:/etc/ssl/certs/haproxy.crt
    docker cp ${WTL_CERTS}/wikitolearn.key wikitolearn-haproxy:/etc/ssl/private/haproxy.key
    docker start wikitolearn-haproxy
    wtl-log scripts/use-instance.sh 7 USE_INSTANCE_DONE "Is up \"${WTL_INSTANCE_NAME}\""
fi
