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
    wtl-log scripts/unuse-instance.sh 3 UNUSE_INSTANCE_START "Bringing down old instance..."
    docker stop wikitolearn-haproxy
    docker rm wikitolearn-haproxy
    wtl-log scripts/unuse-instance.sh 3 UNUSE_INSTANCE_DONE "Is down old instance..."
fi
