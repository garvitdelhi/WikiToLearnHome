#!/bin/bash
cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
 exit 1
 echo "[create/single-node] Error changing directory"
fi


. $WTL_DIR/load-wikitolearn.sh

: '

[[ -z "$WTL_INIT_DB" ]] && export WTL_INIT_DB=0
[[ -z "$WTL_PRODUCTION" ]] && WTL_PRODUCTION=1

if [ "$WTL_BACKUP_ENABLED" == "1" ] ; then
 if [ ! -d "$WTL_BACKUP_PATH" ] ; then
  echo "Missing $WTL_BACKUP_PATH"
  exit 1
 fi
fi
'

test -d $WTL_CONFIGS_DIR || mkdir -p $WTL_CONFIGS_DIR
test -d $WTL_CONFIGS_DIR/mysql-users/ || mkdir -p $WTL_CONFIGS_DIR/mysql-users/
test -d $WTL_CONFIGS_DIR/LocalSettings.d/ || mkdir -p $WTL_CONFIGS_DIR/LocalSettings.d/

export MORE_ARGS=" -e WTL_PRODUCTION=$WTL_PRODUCTION"
if [[ "$WTL_PRODUCTION" == "1" ]] ; then
    export MORE_ARGS=" --restart=always $MORE_ARGS"
fi
    echo "[create/single-node] Running in PRODUCTION mode!"


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

docker inspect ${WTL_INSTANCE_NAME}-ocg &> /dev/null
if [[ $? -ne 0 ]] ; then
    docker create -ti $MORE_ARGS -v wikitolearn-ocg:/tmp/ocg/ocg-output/ --hostname ocg --link ${WTL_INSTANCE_NAME}-parsoid:parsoid --name ${WTL_INSTANCE_NAME}-ocg $WTL_DOCKER_OCG
    echo "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-ocg"
fi

docker inspect ${WTL_INSTANCE_NAME}-websrv &> /dev/null
if [[ $? -ne 0 ]] ; then

    MAIL_SRV_LINK=""


    echo "[create/single-node] Creating docker ${WTL_INSTANCE_NAME}-websrv"
    docker create -ti $MORE_ARGS  \
        -v ${WTL_INSTANCE_NAME}-var-log-apache2:/var/log/apache2 \
        --hostname websrv \
        --name ${WTL_INSTANCE_NAME}-websrv \
        -e USER_UID=$WTL_USER_UID \
        -e USER_GID=$WTL_USER_GID \
        -v $WTL_WORKING_DIR:/var/www/WikiToLearn/ \
        --name ${WTL_INSTANCE_NAME}-websrv \
        --link ${WTL_INSTANCE_NAME}-mysql:mysql \
        --link ${WTL_INSTANCE_NAME}-memcached:memcached \
        --link ${WTL_INSTANCE_NAME}-mathoid:mathoid \
        --link ${WTL_INSTANCE_NAME}-parsoid:parsoid \
        --link ${WTL_INSTANCE_NAME}-ocg:ocg \
        $WTL_DOCKER_WEBSRV

    docker inspect ${WTL_INSTANCE_NAME}-websrv &> /dev/null
    echo "[create/single-node] Copying certs to websrv"
    if [[ $? -ne 0 ]] ; then
        docker cp ${WTL_CERTS}/wikitolearn.crt ${WTL_INSTANCE_NAME}-websrv:/etc/ssl/certs/apache.crt
        if [[ $? -ne 0 ]] ; then
            exit 1
            echo = "[create/single-node] Error: Unable to copy wikitolearn.crt to the webserver"
        fi
        docker cp ${WTL_CERTS}/wikitolearn.key ${WTL_INSTANCE_NAME}-websrv:/etc/ssl/private/apache.key
        if [[ $? -ne 0 ]] ; then
            exit 1
            echo = "[create/single-node] Error: Unable to copy wikitolearn.key to the webserver"
        fi
    fi

    : 'if [[ "$WTL_RELAY_HOST" != "" ]] ; then
        {
        docker exec ${WTL_INSTANCE_NAME}-websrv sed '/^mailhub/d' /etc/ssmtp/ssmtp.conf
        echo "mailhub=${WTL_RELAY_HOST}" | docker exec -i ${WTL_INSTANCE_NAME}-websrv tee -a /etc/ssmtp/ssmtp.conf
        } &> /dev/null
    fi'
fi
