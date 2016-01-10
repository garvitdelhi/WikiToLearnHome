#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./loadconf.sh


if [[ ! -d $W2L_CONFIGS_DIR ]] ; then
 echo "Migging "$W2L_CONFIGS_DIR" directory"
 exit 1
fi

export W2L_INSTANCE_NAME="dev-w2l-dev"

export W2L_USE_MYSQL="docker"
export W2L_DOCKER_MYSQL=mysql:5.6
export W2L_USE_MEMCACHED="docker"
export W2L_DOCKER_MEMCACHED=memcached:1.4.24
export W2L_USE_OCG="docker"
export W2L_DOCKER_OCG=wikitolearn/ocg:0.7.1
export W2L_USE_WEBSRV="docker"
export W2L_DOCKER_WEBSRV=wikitolearn/websrv:0.10.1

. ./run/memcache/$W2L_USE_MYSQL.sh
. ./run/mysql/$W2L_USE_MEMCACHED.sh
. ./run/ocg/$W2L_USE_OCG.sh
. ./run/websrv/$W2L_USE_WEBSRV.sh
