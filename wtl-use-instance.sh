#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

. ./load-wikitolearn.sh
. ./environments/$WTL_ENV.sh

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
    echo "Missing key environment variabile WTL_INSTANCE_NAME in $WTL_ENV.sh"
    exit 1
fi

echo "Bringing up \"${WTL_INSTANCE_NAME}\"..."

CERTS_MOUNT=""
if [[ -d certs/ ]] ; then
    CERTS_MOUNT=" -v $WTL_DIR/certs/:/certs/:ro "
fi

docker run -d --name wikitolearn-haproxy --restart=always \
 -p 80:80 \
 -p 443:443 \
 $CERTS_MOUNT \
 --link ${WTL_INSTANCE_NAME}-websrv:websrv \
 --link ${WTL_INSTANCE_NAME}-parsoid:parsoid \
 $WTL_DOCKER_HAPROXY
