#!/bin/bash
# Install composer dependencies from composer.json in the $1 folder

#check if $1 is null
if [ -z "$1" ]; then
    echo "[composer-dir] Error: required parameter 'path of composer.json'"
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
fi

COMPOSER_DIR="$1"

#call ./load-libs.sh script: load environment variables from const and config file
. ./load-libs.sh

wtl-log composer-dir.sh 2 COMPOSER_DIR_WORKING_DIR "Composing '$COMPOSER_DIR'"

if [[ ! -f $COMPOSER_DIR"/composer.json" ]] ; then
    wtl-log composer-dir.sh 0 COMPOSER_DIR_MISSING_COMPOSER_DOT_JSON "composer.json missing in the directory '$COMPOSER_DIR'"
    exit 1
fi

#check if auth.json is in the composer folder
if [[ ! -f "$WTL_DIR/configs/composer/auth.json" ]] ; then
    wtl-log composer-dir.sh 0 COMPOSER_DIR_MISSING_AUTH "Composer config missing, please run create-config.sh"
    exit 1
fi

if [[ ! -d $WTL_CACHE/composer ]] ; then
    wtl-log composer-dir.sh 3 COMPOSER_DIR_CREATE_CACHE "Creating new dir for cache"
    mkdir -p $WTL_CACHE/composer
fi

docker run --rm -u $WTL_USER_UID:$WTL_USER_GID \
    -e COMPOSER_CACHE_DIR=/cache \
    -e COMPOSER_HOME=/composer \
    -v "$COMPOSER_DIR":/app \
    -v $WTL_CACHE/composer:/cache \
    -v $WTL_CONFIGS_DIR/composer:/composer \
    composer/composer install
