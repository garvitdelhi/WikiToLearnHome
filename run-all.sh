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

. ./run/memcache/$W2L_USE_MYSQL.sh
. ./run/mysql/$W2L_USE_MEMCACHED.sh
. ./run/ocg/$W2L_USE_OCG.sh
. ./run/websrv/$W2L_USE_WEBSRV.sh
