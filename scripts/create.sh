#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "create.sh" ]] ; then
    echo "Wrong way to execute create.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh

if [[ ! -f $WTL_WORKING_DIR/docker-images.conf ]] ; then
    wtl-log wtl-create.sh 0 CREATE_MIGGING_DOCKER_IMAGES_CONF "Missing $WTL_WORKING_DIR/docker-images.conf file"
    exit 1
fi

if [[ ! -f $WTL_WORKING_DIR/databases.conf ]] ; then
    wtl-log wtl-create.sh 0 CREATE_MIGGING_DATABASES_CONF "Missing $WTL_WORKING_DIR/databases.conf file"
    exit 1
fi

if [[ ! -f $WTL_WORKING_DIR/composer-dirs.conf ]] ; then
    wtl-log wtl-create.sh 0 CREATE_MIGGING_COMPOSER_DIRS_CONF "Missing $WTL_WORKING_DIR/composer-dirs.conf file"
    exit 1
fi

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
    wtl-log wtl-create.sh 0 MIGGING_WTL_INSTANCE_NAME "You need the WTL_INSTANCE_NAME env to run create"
    exit 1
fi

$WTL_SCRIPTS/helpers/create/${WTL_HELPER_CREATE}.sh
