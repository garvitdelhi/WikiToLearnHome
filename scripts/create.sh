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
    wtl-event CREATE_MIGGING_DOCKER_IMAGES_CONF $WTL_WORKING_DIR
    exit 1
fi

if [[ ! -f $WTL_WORKING_DIR/databases.conf ]] ; then
    wtl-event CREATE_MIGGING_DATABASES_CONF $WTL_WORKING_DIR
    exit 1
fi

if [[ ! -f $WTL_WORKING_DIR/composer-dirs.conf ]] ; then
    wtl-event CREATE_MIGGING_COMPOSER_DIRS_CONF $WTL_WORKING_DIR
    exit 1
fi

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
    wtl-event MIGGING_WTL_INSTANCE_NAME
    exit 1
fi

$WTL_SCRIPTS/helpers/create/${WTL_HELPER_CREATE}.sh
