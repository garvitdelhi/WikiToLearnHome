#!/bin/bash

#Control the existance of docker instances and create them if they are not existing
docker inspect ${WTL_INSTANCE_NAME}-parsoid &> /dev/null
if [[ $? -ne 0 ]] ; then
    docker create -ti $MORE_ARGS --hostname parsoid --name ${WTL_INSTANCE_NAME}-parsoid $WTL_DOCKER_PARSOID
    echo "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-parsoid"
fi

if [[ "$WTL_MATHOID_NUM_WORKERS" == "" ]] ; then
    export WTL_MATHOID_NUM_WORKERS=1
fi

docker inspect ${WTL_INSTANCE_NAME}-mathoid &> /dev/null
if [[ $? -ne 0 ]] ; then
    docker create -ti $MORE_ARGS --hostname mathoid --name ${WTL_INSTANCE_NAME}-mathoid -e NUM_WORKERS=$MATHOID_NUM_WORKERS $WTL_DOCKER_MATHOID
    echo "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-mathoid with $WTL_MATHOID_NUM_WORKERS workers"
fi

docker inspect ${WTL_INSTANCE_NAME}-memcached &> /dev/null
if [[ $? -ne 0 ]] ; then
    docker create -ti $MORE_ARGS --hostname memcached --name ${WTL_INSTANCE_NAME}-memcached $WTL_DOCKER_MEMCACHED
    echo "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-memcached"
fi

docker inspect ${WTL_INSTANCE_NAME}-mysql &> /dev/null
if [[ $? -ne 0 ]] ; then
    if [[ -f $WTL_CONFIGS_DIR/mysql-users/root ]] ; then
        ROOT_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/root)
        echo "[create/single-node] Using existing mysql root passwd"
    else
        ROOT_PWD=$(echo $RANDOM$RANDOM$(date +%s) | sha256sum | base64 | head -c 32 )
        echo "[create/single-node] Using new mysql root passwd"
        echo $ROOT_PWD > $WTL_CONFIGS_DIR/mysql-users/root
    fi

    if [[ -f $WTL_CONFIGS_DIR/mysql-users/wtlmysql ]] ; then
        WTLMYSQL_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/wtlmysql)
        echo "[create/single-node] Using existing mysql wtlmysql passwd"
    else
        WTLMYSQL_PWD=$(echo $RANDOM$RANDOM$(date +%s) | sha256sum | base64 | head -c 32 )
        echo "[create/single-node] Using new mysql wtlmysql passwd"
        echo $WTLMYSQL_PWD > $WTL_CONFIGS_DIR/mysql-users/wtlmysql
    fi

    docker create -ti $MORE_ARGS -v ${WTL_INSTANCE_NAME}-var-lib-mysql:/var/lib/mysql --hostname mysql --name ${WTL_INSTANCE_NAME}-mysql -e MYSQL_ROOT_PASSWORD=$ROOT_PWD $WTL_DOCKER_MYSQL
    echo "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-mysql"

    echo "[client]" > $WTL_CONFIGS_DIR/mysql-root-password.cnf
    echo "user=root" >> $WTL_CONFIGS_DIR/mysql-root-password.cnf
    echo "password=$ROOT_PWD" >> $WTL_CONFIGS_DIR/mysql-root-password.cnf
fi

docker inspect ${WTL_INSTANCE_NAME}-restbase &> /dev/null
if [[ $? -ne 0 ]] ; then
    docker create -ti $MORE_ARGS --hostname restbase --link ${WTL_INSTANCE_NAME}-parsoid:parsoid --name ${WTL_INSTANCE_NAME}-restbase $WTL_DOCKER_RESTBASE
    echo "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-restbase"
fi

