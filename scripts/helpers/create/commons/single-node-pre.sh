#!/bin/bash
. ./load-libs.sh

#Control the existance of docker instances and create them if they are not existing
if ! docker inspect ${WTL_INSTANCE_NAME}-parsoid &> /dev/null ; then
    docker create -ti $MORE_ARGS --hostname parsoid --name ${WTL_INSTANCE_NAME}-parsoid $WTL_DOCKER_PARSOID
    wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-parsoid"
fi

if [[ "$WTL_MATHOID_NUM_WORKERS" == "" ]] ; then
    wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "Using the default WTL_MATHOID_NUM_WORKERS value (is 1)"
    export WTL_MATHOID_NUM_WORKERS=1
else
    wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "Using "$WTL_MATHOID_NUM_WORKERS" mathoid workers"
fi

if [[ "$WTL_RESTBASE_CASSANDRA_HOSTS" == "" ]] ; then
    wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "Using sqlite as restbase backend"
    export WTL_RESTBASE_CASSANDRA_HOSTS=""
fi

if ! docker inspect ${WTL_INSTANCE_NAME}-mathoid &> /dev/null ; then
    docker create -ti $MORE_ARGS --hostname mathoid --name ${WTL_INSTANCE_NAME}-mathoid -e NUM_WORKERS=$WTL_MATHOID_NUM_WORKERS $WTL_DOCKER_MATHOID
    wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-mathoid with $WTL_MATHOID_NUM_WORKERS workers"
fi


if ! docker inspect ${WTL_INSTANCE_NAME}-memcached &> /dev/null ; then
    docker create -ti $MORE_ARGS --hostname memcached --name ${WTL_INSTANCE_NAME}-memcached $WTL_DOCKER_MEMCACHED
    wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-memcached"
fi


if ! docker inspect ${WTL_INSTANCE_NAME}-mysql &> /dev/null ; then
    if [[ -f $WTL_CONFIGS_DIR/mysql-users/root ]] ; then
        ROOT_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/root)
        wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "[create/single-node] Using existing mysql root passwd"
    else
        ROOT_PWD=$(echo $RANDOM$RANDOM$(date +%s) | sha256sum | base64 | head -c 32 )
        wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "[create/single-node] Using new mysql root passwd"
        echo $ROOT_PWD > $WTL_CONFIGS_DIR/mysql-users/root
    fi

    if [[ -f $WTL_CONFIGS_DIR/mysql-users/wtlmysql ]] ; then
        WTLMYSQL_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/wtlmysql)
        wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "[create/single-node] Using existing mysql wtlmysql passwd"
    else
        WTLMYSQL_PWD=$(echo $RANDOM$RANDOM$(date +%s) | sha256sum | base64 | head -c 32 )
        wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "[create/single-node] Using new mysql wtlmysql passwd"
        echo $WTLMYSQL_PWD > $WTL_CONFIGS_DIR/mysql-users/wtlmysql
    fi

    docker create -ti $MORE_ARGS -v ${WTL_VOLUME_DIR}${WTL_INSTANCE_NAME}-var-lib-mysql:/var/lib/mysql --hostname mysql --name ${WTL_INSTANCE_NAME}-mysql -e MYSQL_ROOT_PASSWORD=$ROOT_PWD $WTL_DOCKER_MYSQL
    wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-mysql"

    echo "[client]" > $WTL_CONFIGS_DIR/mysql-root-password.cnf
    echo "user=root" >> $WTL_CONFIGS_DIR/mysql-root-password.cnf
    echo "password=$ROOT_PWD" >> $WTL_CONFIGS_DIR/mysql-root-password.cnf
fi


if ! docker inspect ${WTL_INSTANCE_NAME}-restbase &> /dev/null ; then
    docker create -ti $MORE_ARGS --hostname restbase \
        -e CASSANDRA_HOSTS=$WTL_RESTBASE_CASSANDRA_HOSTS \
        --link ${WTL_INSTANCE_NAME}-parsoid:parsoid \
        --link ${WTL_INSTANCE_NAME}-mathoid:mathoid \
        --name ${WTL_INSTANCE_NAME}-restbase $WTL_DOCKER_RESTBASE
    wtl-log scripts/helpers/create/commons/single-node-pre.sh 7 NN "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-restbase"
fi
