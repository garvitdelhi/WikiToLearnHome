#!/bin/bash
. ./load-libs.sh

if ! docker start ${WTL_INSTANCE_NAME}-parsoid ; then
    wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] FATAL ERROR: MISSING PARSOID"
    exit 1
fi

if ! docker start ${WTL_INSTANCE_NAME}-mathoid ; then
    wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node]  FATAL ERROR: MISSING MATHOID"
    exit 1
fi


if ! docker start ${WTL_INSTANCE_NAME}-memcached ; then
    wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] FATAL ERROR: MISSING MEMCACHED"
    exit 1
fi


if ! docker start ${WTL_INSTANCE_NAME}-mysql; then
    wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] FATAL ERROR: MISSING MYSQL"
    exit 1
else
    ROOT_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/root)
    WTLMYSQL_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/wtlmysql)
    wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] mysql root password: $ROOT_PWD"

    docker cp $WTL_CONFIGS_DIR/mysql-root-password.cnf ${WTL_INSTANCE_NAME}-mysql:/root/mysql-root-password.cnf

    wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] waiting for mysql initialization"
    while ! docker exec ${WTL_INSTANCE_NAME}-mysql mysql --defaults-file=/root/mysql-root-password.cnf -e "SELECT 1" &> /dev/null
    do
        wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] Waiting for mysql... (this can take some time, usually less then 5 minute)"
        sleep 1
    done
    docker cp $WTL_CONFIGS_DIR/mysql-root-password.cnf ${WTL_INSTANCE_NAME}-mysql:/root/.my.cnf
    wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] mysql running"

    wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] Granting privileges to mysql users"
    echo "GRANT ALL PRIVILEGES ON * . * TO 'wtlmysql'@'%' IDENTIFIED BY '$WTLMYSQL_PWD';" | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql
    if ! docker exec ${WTL_INSTANCE_NAME}-mysql mysql -uwtlmysql -p$WTLMYSQL_PWD -e "SELECT 1" &> /dev/null ; then
        wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] FATAL ERROR: mysql authentication didn't work"
        exit 1
    fi

    wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] Creating '$WTL_CONFIGS_DIR/LocalSettings.d/mysql-username-and-password.php'"
    {
        echo "<?php"
        echo "\$wgDBuser = 'wtlmysql';"
        echo "\$wgDBpassword = '$WTLMYSQL_PWD';"
    } > $WTL_CONFIGS_DIR/LocalSettings.d/mysql-username-and-password.php

    for dbname in $(cat $WTL_WORKING_DIR/databases.conf)
    do
        wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] DB: $dbname"
        if [[ $dbname =~ ^[a-z_]+$ ]]; then
            docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql -e "CREATE DATABASE IF NOT EXISTS $dbname"
        else
            wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] DB name '$dbname' not allowed"
        fi
    done
fi

if ! docker start ${WTL_INSTANCE_NAME}-parsoid ; then
    wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] FATAL ERROR: MISSING PARSOID"
    exit 1
fi

if ! docker start ${WTL_INSTANCE_NAME}-restbase ; then
    wtl-log scripts/helpers/start/commons/single-node-pre.sh 7 NN "[start/single-node] FATAL ERROR: MISSING RESTBASE"
    exit 1
fi

