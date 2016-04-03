#!/bin/bash
docker start ${WTL_INSTANCE_NAME}-parsoid
if [[ $? -ne 0 ]] ; then
    echo "[start/single-node] FATAL ERROR: MISSING PARSOID"
    exit 1
fi

docker start ${WTL_INSTANCE_NAME}-mathoid
if [[ $? -ne 0 ]] ; then
    echo "[start/single-node]  FATAL ERROR: MISSING MATHOID"
    exit 1
fi

docker start ${WTL_INSTANCE_NAME}-memcached
if [[ $? -ne 0 ]] ; then
    echo "[start/single-node] FATAL ERROR: MISSING MEMCACHED"
    exit 1
fi

docker start ${WTL_INSTANCE_NAME}-mysql
if [[ $? -ne 0 ]] ; then
    echo "[start/single-node] FATAL ERROR: MISSING MYSQL"
    exit 1
else
    ROOT_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/root)
    WTLMYSQL_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/wtlmysql)
    echo "[start/single-node] mysql root password: $ROOT_PWD"

    docker cp $WTL_CONFIGS_DIR/mysql-root-password.cnf ${WTL_INSTANCE_NAME}-mysql:/root/mysql-root-password.cnf

    echo "[start/single-node] waiting for mysql initialization"
    while ! docker exec ${WTL_INSTANCE_NAME}-mysql mysql --defaults-file=/root/mysql-root-password.cnf -e "SELECT 1"
    do
        sleep 1
    done
    docker cp $WTL_CONFIGS_DIR/mysql-root-password.cnf ${WTL_INSTANCE_NAME}-mysql:/root/.my.cnf
    echo "[start/single-node] mysql running"

    echo "[start/single-node] Granting privileges to mysql users"
    echo "GRANT ALL PRIVILEGES ON * . * TO 'wtlmysql'@'%' IDENTIFIED BY '$WTLMYSQL_PWD';" | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql
    if ! docker exec ${WTL_INSTANCE_NAME}-mysql mysql -uwtlmysql -p$WTLMYSQL_PWD -e "SELECT 1" ; then
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

docker start ${WTL_INSTANCE_NAME}-parsoid
if [[ $? -ne 0 ]] ; then
    echo "[start/single-node] FATAL ERROR: MISSING PARSOID"
    exit 1
fi

docker start ${WTL_INSTANCE_NAME}-restbase
if [[ $? -ne 0 ]] ; then
    echo "[start/single-node] FATAL ERROR: MISSING RESTBASE"
    exit 1
fi

docker start ${WTL_INSTANCE_NAME}-websrv
if [[ $? -ne 0 ]] ; then
    echo "[start/single-node] FATAL ERROR: MISSING WEBSRV"
    exit 1
fi

if [[ ! -f $WTL_CONFIGS_DIR/LocalSettings.d/wgSecretKey.php ]] ; then
    echo "[start/single-node] Creating new '$WTL_CONFIGS_DIR/LocalSettings.d/wgSecretKey.php' file"
    WG_SECRET_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
    {
        echo "<?php"
        echo "\$wgSecretKey = '$WG_SECRET_KEY';"
    } > $WTL_CONFIGS_DIR/LocalSettings.d/wgSecretKey.php
else
    echo "[start/single-node] Using the existent '$WTL_CONFIGS_DIR/LocalSettings.d/wgSecretKey.php' file"
fi

rsync -av --delete --exclude .placeholder $WTL_CONFIGS_DIR/LocalSettings.d/ $WTL_WORKING_DIR/LocalSettings.d/

docker exec -ti ${WTL_INSTANCE_NAME}-websrv su -s /var/www/WikiToLearn/fix-symlinks.sh www-data
docker exec -ti ${WTL_INSTANCE_NAME}-websrv su -s /var/www/WikiToLearn/fix-configs.sh www-data

