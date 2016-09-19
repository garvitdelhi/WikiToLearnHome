#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "unuse-instance.sh" ]] ; then
    echo "Wrong way to execute unuse-instance.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

if docker inspect wikitolearn-haproxy &> /dev/null ; then
    . $WTL_SCRIPTS/load-productoin-instance.sh
    wtl-event UNUSE_INSTANCE_START ${WTL_INSTANCE_NAME}
    docker stop wikitolearn-haproxy
    docker rm wikitolearn-haproxy
    wtl-event UNUSE_INSTANCE_DONE ${WTL_INSTANCE_NAME}
fi
