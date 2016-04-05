#!/bin/bash


if ! docker start ${WTL_INSTANCE_NAME}-parsoid ; then
    echo "[start/single-node] FATAL ERROR: MISSING PARSOID"
    exit 1
fi

if ! docker start ${WTL_INSTANCE_NAME}-mathoid ; then
    echo "[start/single-node]  FATAL ERROR: MISSING MATHOID"
    exit 1
fi


if ! docker start ${WTL_INSTANCE_NAME}-memcached ; then
    echo "[start/single-node] FATAL ERROR: MISSING MEMCACHED"
    exit 1
fi


if ! docker start ${WTL_INSTANCE_NAME}-mysql; then
    echo "[start/single-node] FATAL ERROR: MISSING MYSQL"
    exit 1
else
    ROOT_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/root)
    WTLMYSQL_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/wtlmysql)
    echo "[start/single-node] mysql root password: $ROOT_PWD"

    docker cp $WTL_CONFIGS_DIR/mysql-root-password.cnf ${WTL_INSTANCE_NAME}-mysql:/root/mysql-root-password.cnf

    echo "[start/single-node] waiting for mysql initialization"
    while ! docker exec ${WTL_INSTANCE_NAME}-mysql mysql --defaults-file=/root/mysql-root-password.cnf -e "SELECT 1" &> /dev/null
    do
        echo "[start/single-node] Waiting for mysql... (this can take some time, usually less then 1 minute)"
        sleep 1
    done
    docker cp $WTL_CONFIGS_DIR/mysql-root-password.cnf ${WTL_INSTANCE_NAME}-mysql:/root/.my.cnf
    echo "[start/single-node] mysql running"

    echo "[start/single-node] Granting privileges to mysql users"
    echo "GRANT ALL PRIVILEGES ON * . * TO 'wtlmysql'@'%' IDENTIFIED BY '$WTLMYSQL_PWD';" | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql
    if ! docker exec ${WTL_INSTANCE_NAME}-mysql mysql -uwtlmysql -p$WTLMYSQL_PWD -e "SELECT 1" &> /dev/null ; then
        echo "[start/single-node] FATAL ERROR: mysql authentication didn't work"
        exit 1
    fi

    echo "[start/single-node] Creating '$WTL_CONFIGS_DIR/LocalSettings.d/mysql-username-and-password.php'"
    {
        echo "<?php"
        echo "\$wgDBuser = 'wtlmysql';"
        echo "\$wgDBpassword = '$WTLMYSQL_PWD';"
    } > $WTL_CONFIGS_DIR/LocalSettings.d/mysql-username-and-password.php

    for dbname in $(cat $WTL_WORKING_DIR/databases.conf)
    do
        echo "[start/single-node] DB: $dbname"
        if [[ $dbname =~ ^[a-z_]+$ ]]; then
            docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql -e "CREATE DATABASE IF NOT EXISTS $dbname"
        else
            echo "[start/single-node] DB name '$dbname' not allowed"
        fi
    done
fi

if ! docker start ${WTL_INSTANCE_NAME}-parsoid ; then
    echo "[start/single-node] FATAL ERROR: MISSING PARSOID"
    exit 1
fi

if ! docker start ${WTL_INSTANCE_NAME}-restbase ; then
    echo "[start/single-node] FATAL ERROR: MISSING RESTBASE"
    exit 1
fi

