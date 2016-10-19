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

if [[ "$WTL_MATHOID_NUM_WORKERS" == "" ]] ; then
    wtl-event MATHOID_NUM_WORKERS_DEFAULT_VALUE
    export WTL_MATHOID_NUM_WORKERS=4
else
    wtl-event MATHOID_NUM_WORKERS_CONF_VALUE $WTL_MATHOID_NUM_WORKERS
fi

if [[ "$WTL_RESTBASE_NUM_WORKERS" == "" ]] ; then
    wtl-event RESTBASE_NUM_WORKERS_DEFAULT_VALUE
    export WTL_RESTBASE_NUM_WORKERS=4
else
    wtl-event RESTBASE_NUM_WORKERS_CONF_VALUE $WTL_RESTBASE_NUM_WORKERS
fi

if [[ "$WTL_HHVM_NUM_WORKERS" == "" ]] ; then
    wtl-event HHVM_NUM_WORKERS_DEFAULT_VALUE
    export WTL_HHVM_NUM_WORKERS=1
else
    wtl-event HHVM_NUM_WORKERS_CONF_VALUE $WTL_HHVM_NUM_WORKERS
fi

if [[ "$WTL_RESTBASE_CASSANDRA_HOSTS" == "" ]] ; then
    wtl-event RESTBASE_CASSANDRA_HOSTS_EMPTY
    export WTL_RESTBASE_CASSANDRA_HOSTS=""
fi

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
