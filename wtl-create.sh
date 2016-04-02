#!/bin/bash
set -e
if [[ $(basename $0) != "wtl-create.sh" ]] ; then
    echo "Wrong way to execute wtl-create.sh"
    exit 1
fi

cd $(dirname $(realpath $0))

if [[ ! -f "wtl-create.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh

. $WTL_DIR/environments/${WTL_ENV}.sh

if [[ ! -f $WTL_WORKING_DIR/docker-images.conf ]] ; then
    wtl-log wtl-create.sh 0 WTL_CREATE_MIGGING_DOCKER_IMAGES_CONF "Missing $WTL_WORKING_DIR/docker-images.conf file"
    exit 1
fi

if [[ ! -f $WTL_WORKING_DIR/databases.conf ]] ; then
    wtl-log wtl-create.sh 0 WTL_CREATE_MIGGING_DATABASES_CONF "Missing $WTL_WORKING_DIR/databases.conf file"
    exit 1
fi

if [[ ! -f $WTL_WORKING_DIR/composer-dirs.conf ]] ; then
    wtl-log wtl-create.sh 0 WTL_CREATE_MIGGING_COMPOSER_DIRS_CONF "Missing $WTL_WORKING_DIR/composer-dirs.conf file"
    exit 1
fi

. $WTL_DIR/make-self-signed-certs.sh

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
    wtl-log wtl-create.sh 0 WTL_CREATE_MIGGING_WTL_INSTANCE_NAME "wtl-create You need the WTL_INSTANCE_NAME env"
    exit 1
fi

. $WTL_DIR/helpers/create/${WTL_HELPER_CREATE}.sh
