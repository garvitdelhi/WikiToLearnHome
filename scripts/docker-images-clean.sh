#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "docker-images-clean.sh" ]] ; then
    echo "Wrong way to execute docker-images-clean.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

if [[ $(docker images --filter "dangling=true" -q | wc -l) -gt 0 ]] ; then
    docker rmi $(docker images --filter "dangling=true" -q)
fi
