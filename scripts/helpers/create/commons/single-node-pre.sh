#!/bin/bash
. ./load-libs.sh

#Control the existance of docker instances and create them if they are not existing
if ! docker inspect ${WTL_INSTANCE_NAME}-parsoid &> /dev/null ; then
    docker create -ti $MORE_ARGS --hostname parsoid --name ${WTL_INSTANCE_NAME}-parsoid $WTL_DOCKER_PARSOID
    wtl-event CREATE_DOCKER_PARSOID ${WTL_INSTANCE_NAME}
fi

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

if [[ "$WTL_RESTBASE_CASSANDRA_HOSTS" == "" ]] ; then
    wtl-event RESTBASE_CASSANDRA_HOSTS_EMPTY
    export WTL_RESTBASE_CASSANDRA_HOSTS=""
fi

if ! docker inspect ${WTL_INSTANCE_NAME}-mathoid &> /dev/null ; then
    docker create -ti $MORE_ARGS --hostname mathoid --name ${WTL_INSTANCE_NAME}-mathoid -e NUM_WORKERS=$WTL_MATHOID_NUM_WORKERS $WTL_DOCKER_MATHOID
    wtl-event CREATE_DOCKER_MATHOID ${WTL_INSTANCE_NAME} $WTL_MATHOID_NUM_WORKERS
fi


if ! docker inspect ${WTL_INSTANCE_NAME}-memcached &> /dev/null ; then
    docker create -ti $MORE_ARGS --hostname memcached --name ${WTL_INSTANCE_NAME}-memcached $WTL_DOCKER_MEMCACHED
    wtl-event CREATE_DOCKER_MEMCACHED ${WTL_INSTANCE_NAME}
fi


if ! docker inspect ${WTL_INSTANCE_NAME}-mysql &> /dev/null ; then
    if [[ -f $WTL_CONFIGS_DIR/mysql-users/root ]] ; then
        ROOT_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/root)
        wtl-event MYSQL_OLD_ROOT_PASSWORD
    else
        ROOT_PWD=$(echo $RANDOM$RANDOM$(date +%s) | sha256sum | base64 | head -c 32 )
        wtl-event MYSQL_NEW_ROOT_PASSWORD
        echo $ROOT_PWD > $WTL_CONFIGS_DIR/mysql-users/root
    fi

    if [[ -f $WTL_CONFIGS_DIR/mysql-users/wtlmysql ]] ; then
        WTLMYSQL_PWD=$(cat $WTL_CONFIGS_DIR/mysql-users/wtlmysql)
        wtl-event MYSQL_OLD_USER_PASSWORD
    else
        WTLMYSQL_PWD=$(echo $RANDOM$RANDOM$(date +%s) | sha256sum | base64 | head -c 32 )
        wtl-event MYSQL_NEW_USER_PASSWORD
        echo $WTLMYSQL_PWD > $WTL_CONFIGS_DIR/mysql-users/wtlmysql
    fi

    if test ! -d $WTL_CONFIGS_DIR/mysql-config.d/
    then
        mkdir $WTL_CONFIGS_DIR/mysql-config.d/
    fi
    docker create -ti $MORE_ARGS -v $WTL_CONFIGS_DIR/mysql-config.d/:/etc/mysql/conf.d -v ${WTL_VOLUME_DIR}${WTL_INSTANCE_NAME}-var-lib-mysql:/var/lib/mysql --hostname mysql --name ${WTL_INSTANCE_NAME}-mysql -e MYSQL_ROOT_PASSWORD=$ROOT_PWD $WTL_DOCKER_MYSQL
    wtl-event CREATE_DOCKER_MYSQL ${WTL_INSTANCE_NAME}

    echo "[client]" > $WTL_CONFIGS_DIR/mysql-root-password.cnf
    echo "user=root" >> $WTL_CONFIGS_DIR/mysql-root-password.cnf
    echo "password=$ROOT_PWD" >> $WTL_CONFIGS_DIR/mysql-root-password.cnf
fi


if ! docker inspect ${WTL_INSTANCE_NAME}-restbase &> /dev/null ; then
    docker create -ti $MORE_ARGS --hostname restbase \
        -e CASSANDRA_HOSTS=$WTL_RESTBASE_CASSANDRA_HOSTS \
        -e NUM_WORKERS=$WTL_RESTBASE_NUM_WORKERS \
        --link ${WTL_INSTANCE_NAME}-parsoid:parsoid \
        --link ${WTL_INSTANCE_NAME}-mathoid:mathoid \
        --name ${WTL_INSTANCE_NAME}-restbase $WTL_DOCKER_RESTBASE
    wtl-event CREATE_DOCKER_RESTBASE ${WTL_INSTANCE_NAME}
fi
