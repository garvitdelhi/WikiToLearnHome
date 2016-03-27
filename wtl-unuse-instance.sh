#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

. ./load-wikitolearn.sh

echo "Bringing down..."

docker inspect wikitolearn-haproxy &> /dev/null
if [[ $? -eq 0 ]] ; then
    docker stop wikitolearn-haproxy
    docker rm wikitolearn-haproxy
fi
