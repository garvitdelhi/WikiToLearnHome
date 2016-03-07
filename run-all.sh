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

. ./run/memcache/$WTL_USE_MYSQL.sh
. ./run/mysql/$WTL_USE_MEMCACHED.sh
. ./run/ocg/$WTL_USE_OCG.sh
. ./run/websrv/$WTL_USE_WEBSRV.sh
