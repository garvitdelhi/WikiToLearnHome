#!/bin/bash
# Install composer dependencies from composer.json in the $1 folder 

#check existence of the directory WikiToLearn
if [[ "$WTL_DIR" == "" ]] ; then
 echo "You can't run this script"
 exit 1
fi

#check if $1 is null
if [ -z "$1" ]; then
    echo "Warning: required parameter 'location of composer.json'" 
    exit -1
fi

echo $1

#cd to current script folder
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

#call ./load-wikitolearn.sh script: load environment variables from const and config file
. ./load-wikitolearn.sh

#check if auth.json is in the composer folder
if [[ ! -f "$WTL_DIR/configs/composer/auth.json" ]] ; then
    echo "Composer config missing, please run create-config.sh"
    exit 1
fi

mkdir -p $WTL_CACHE/composer

cd $1

echo "composer"
pwd

docker run --rm -u $WTL_USER_UID:$WTL_USER_GID -v $(pwd):/app -e COMPOSER_CACHE_DIR=/cache -e COMPOSER_HOME=/composer -v $WTL_CACHE/composer:/cache -v $WTL_CONFIGS_DIR/composer:/composer composer/composer install -v
