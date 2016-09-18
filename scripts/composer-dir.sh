#!/bin/bash
# Install composer dependencies from composer.json in the $1 folder
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "composer-dir.sh" ]] ; then
    echo "Wrong way to execute composer-dir.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi
. ./load-libs.sh
#check if $1 is null
if [ -z "$1" ]; then
    wtl-event COMPOSER_DIR_MISSING_PATH_COMPOSER_JSON
    exit 1
fi

COMPOSER_DIR="$1"

#call ./load-libs.sh script: load environment variables from const and config file
. ./load-libs.sh

wtl-event COMPOSER_DIR_WORKING_DIR $COMPOSER_DIR

if [[ ! -f $COMPOSER_DIR"/composer.json" ]] ; then
    wtl-event COMPOSER_DIR_MISSING_COMPOSER_DOT_JSON $COMPOSER_DIR
    exit 1
fi

#check if auth.json is in the composer folder
if [[ ! -f "$WTL_DIR/configs/composer/auth.json" ]] ; then
    wtl-event COMPOSER_DIR_MISSING_AUTH
    exit 1
fi

if [[ ! -d $WTL_CACHE/composer ]] ; then
    wtl-event COMPOSER_DIR_CREATE_CACHE
    mkdir -p $WTL_CACHE/composer
fi

docker run --rm -u $WTL_USER_UID:$WTL_USER_GID \
    -e COMPOSER_CACHE_DIR=/cache \
    -e COMPOSER_HOME=/composer \
    -v "$COMPOSER_DIR":/app \
    -v $WTL_CACHE/composer:/cache \
    -v $WTL_CONFIGS_DIR/composer:/composer \
    composer/composer install
