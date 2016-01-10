#!/bin/bash
echo "Bringing up "${W2L_INSTANCE_NAME}"..."

docker inspect wikitolearn-haproxy &> /dev/null
if [[ $? -eq 0 ]] ; then
 docker stop wikitolearn-haproxy
 docker rm wikitolearn-haproxy
fi

CERTS_MOUNT=""
if [[ -d certs/ ]] ; then
 CERTS_MOUNT=" -v "$(pwd)"/certs/:/certs/:ro "
fi

docker run -d --name wikitolearn-haproxy --restart=always \
 -p 80:80 \
 -p 443:443 \
 --link ${W2L_INSTANCE_NAME}-websrv:websrv \
 --link ${W2L_INSTANCE_NAME}-ocg:ocg \
 $W2L_DOCKER_HAPROXY
