#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh


if [[ ! -d $W2L_CONFIGS_DIR ]] ; then
 echo "Migging "$W2L_CONFIGS_DIR" directory"
 exit 1
fi

export W2L_INSTANCE_NAME="dev-w2l-dev"

export W2L_USE_HAPROXY="docker"
export W2L_DOCKER_HAPROXY=wikitolearn/haproxy:0.5
