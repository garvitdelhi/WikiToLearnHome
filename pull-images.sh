#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
    echo "[pull-images] Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh
. ./environments/$WTL_ENV.sh

if [[ "$WTL_SKIP_OCG_DOCKER" == "1" ]] ; then
    WTL_DOCKER_OCG=""
fi

for img in $WTL_DOCKER_MYSQL $WTL_DOCKER_MEMCACHED $WTL_DOCKER_OCG $WTL_DOCKER_WEBSRV $WTL_DOCKER_HAPROXY $WTL_DOCKER_PARSOID $WTL_DOCKER_MATHOID ; do
    echo "[pull-images] Pulling '$img'"
    docker pull $img

    echo "[pull-images] '$img' pulled, inspecting"
    docker inspect $img &> /dev/null
    if [[ $? -ne 0 ]] ; then
        echo "[pull-images] Error downloading '$img' image. Check Internet connection and then restart the script"
        exit 1
    fi
    
    echo "[pull-images] '$img' pulled and it's fine!"
done