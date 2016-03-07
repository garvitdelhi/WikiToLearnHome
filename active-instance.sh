#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh


if [[ ! -d $WTL_CONFIGS_DIR ]] ; then
 echo "Migging "$WTL_CONFIGS_DIR" directory"
 exit 1
fi

export WTL_INSTANCE_NAME="dev-wtl-dev"

export WTL_USE_HAPROXY="docker"
export WTL_DOCKER_HAPROXY=wikitolearn/haproxy:0.5
