#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

if [[ "$WTL_RUN_VERSION" != "current" ]] ; then
 . ./create-archive.sh "$WTL_RUN_VERSION"
fi

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
 echo "Development env"
 export WTL_INSTANCE_NAME="wtl-dev"
 . $WTL_REPO_DIR/docker-images.conf
fi

if [[ ! -d $WTL_CONFIGS_DIR ]] ; then
 echo "Migging "$WTL_CONFIGS_DIR" directory"
 exit 1
fi

if [[ "$WTL_USE_DEFAULT" == "" ]] ; then
 echo "Missing the WTL_USE_DEFAULT"
 exit 1
fi

echo "Start mysql system..."
# check if there is an override for mysql
if [[ "$WTL_USE_MYSQL" == "" ]] ; then
 export REAL_WTL_USE_MYSQL=$WTL_USE_DEFAULT
else
 export REAL_WTL_USE_MYSQL=$WTL_USE_MYSQL
fi
# check if the helper exists
if [[ -f ./run/mysql/$REAL_WTL_USE_MYSQL.sh ]] ; then
 . ./run/mysql/$REAL_WTL_USE_MYSQL.sh
else
 echo "Missing the ./run/memcache/$REAL_WTL_USE_MYSQL.sh file"
 exit 1
fi

echo "Start memcached system..."
# check if there is an override for memcached
if [[ "$WTL_USE_MEMCACHED" == "" ]] ; then
 export REAL_WTL_USE_MEMCACHED=$WTL_USE_DEFAULT
else
 export REAL_WTL_USE_MEMCACHED=$WTL_USE_MEMCACHED
fi
# check if the helper exists
if [[ -f ./run/memcache/$REAL_WTL_USE_MEMCACHED.sh ]] ; then
 . ./run/memcache/$REAL_WTL_USE_MEMCACHED.sh
else
 echo "Missing the ./run/mysql/$REAL_WTL_USE_MEMCACHED.sh file"
 exit 1
fi

# check if there is an override for parsoid
if [[ "$WTL_USE_PARSOID" == "" ]] ; then
 export REAL_WTL_USE_PARSOID=$WTL_USE_DEFAULT
else
 export REAL_WTL_USE_PARSOID=$WTL_USE_PARSOID
fi
# check if the helper exists
if [[ -f ./run/parsoid/$REAL_WTL_USE_PARSOID.sh ]] ; then
 . ./run/parsoid/$REAL_WTL_USE_PARSOID.sh
else
 echo "Missing the ./run/mysql/$REAL_WTL_USE_PARSOID.sh file"
 exit 1
fi


# check if there is an override for mathoid
if [[ "$WTL_USE_MATHOID" == "" ]] ; then
 export REAL_WTL_USE_MATHOID=$WTL_USE_DEFAULT
else
 export REAL_WTL_USE_MATHOID=$WTL_USE_MATHOID
fi
# check if the helper exists
if [[ -f ./run/mathoid/$REAL_WTL_USE_MATHOID.sh ]] ; then
 . ./run/mathoid/$REAL_WTL_USE_MATHOID.sh
else
 echo "Missing the ./run/mysql/$REAL_WTL_USE_MATHOID.sh file"
 exit 1
fi

# check if there is an override for ocg
if [[ "$WTL_USE_OCG" == "" ]] ; then
 export REAL_WTL_USE_OCG=$WTL_USE_DEFAULT
else
 export REAL_WTL_USE_OCG=$WTL_USE_OCG
fi
# check if the helper exists
if [[ -f ./run/ocg/$REAL_WTL_USE_OCG.sh ]] ; then
 . ./run/ocg/$REAL_WTL_USE_OCG.sh
else
 echo "Missing the ./run/ocg/$REAL_WTL_USE_OCG.sh file"
 exit 1
fi

# check if there is an override for webserver
if [[ "$WTL_USE_WEBSRV" == "" ]] ; then
 export REAL_WTL_USE_WEBSRV=$WTL_USE_DEFAULT
else
 export REAL_WTL_USE_WEBSRV=$WTL_USE_WEBSRV
fi
# check if the helper exists
if [[ -f ./run/websrv/$REAL_WTL_USE_WEBSRV.sh ]] ; then
 . ./run/websrv/$REAL_WTL_USE_WEBSRV.sh
else
 echo "Missing the ./run/ocg/$REAL_WTL_USE_WEBSRV.sh file"
 exit 1
fi



env | grep REF_WTL_
