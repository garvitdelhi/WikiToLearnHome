#!/bin/bash
if [ -z "$1" ]; then 
    echo "Warning: required parameter 'location of composer.json'" 
    exit -1 
fi

echo $1

cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

if [[ -f "$WTL_DIR/configs/composer/config.json" ]] ; then
    echo "Composer config OK"
else
    echo "Composer config missing, please run create-config.sh"
    exit 1
fi

mkdir -p $WTL_DIR/cache/composer

cd $1

docker run --rm -u $(id -u):$(id -g) -v $(pwd):/app -e COMPOSER_CACHE_DIR=/cache -e COMPOSER_HOME=/composer -v $WTL_DIR/cache/composer:/cache -v $WTL_DIR/configs/composer:/composer composer/composer install -v
