#!/bin/bash
# Install composer dependencies from composer.json in the $1 folder

#check if $1 is null
if [ -z "$1" ]; then
    echo "[do-one-composer] Error: required parameter 'path of composer.json'"
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
fi

DO_ONE_COMPOSER_DIR="$1"

#call ./load-libs.sh script: load environment variables from const and config file
. ./load-libs.sh

wtl-log do-one-composer.sh 2 DO_ONE_COMPOSER_WORKING_DIR "Composing '$DO_ONE_COMPOSER_DIR'"

if [[ ! -f $DO_ONE_COMPOSER_DIR"/composer.json" ]] ; then
    wtl-log do-one-composer.sh 0 DO_ONE_COMPOSER_MISSING_COMPOSER_DOT_JSON "composer.json missing in the directory '$DO_ONE_COMPOSER_DIR'"
    exit 1
fi

#check if auth.json is in the composer folder
if [[ ! -f "$WTL_DIR/configs/composer/auth.json" ]] ; then
    wtl-log do-one-composer.sh 0 DO_ONE_COMPOSER_MISSING_AUTH "Composer config missing, please run create-config.sh"
    exit 1
fi

if [[ ! -d $WTL_CACHE/composer ]] ; then
    wtl-log do-one-composer.sh 3 DO_ONE_COMPOSER_CREATE_CACHE "[do-one-composer] Creating new dir for cache"
    mkdir -p $WTL_CACHE/composer
fi

docker run --rm -u $WTL_USER_UID:$WTL_USER_GID \
    -e COMPOSER_CACHE_DIR=/cache \
    -e COMPOSER_HOME=/composer \
    -v "$DO_ONE_COMPOSER_DIR":/app \
    -v $WTL_CACHE/composer:/cache \
    -v $WTL_CONFIGS_DIR/composer:/composer \
    composer/composer install
