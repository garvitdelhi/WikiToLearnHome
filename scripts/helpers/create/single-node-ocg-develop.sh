#!/bin/bash
test -d $WTL_CONFIGS_DIR || mkdir -p $WTL_CONFIGS_DIR
test -d $WTL_CONFIGS_DIR/mysql-users/ || mkdir -p $WTL_CONFIGS_DIR/mysql-users/
test -d $WTL_CONFIGS_DIR/LocalSettings.d/ || mkdir -p $WTL_CONFIGS_DIR/LocalSettings.d/

export MORE_ARGS=" -e WTL_PRODUCTION=$WTL_PRODUCTION"
if [[ "$WTL_PRODUCTION" == "1" ]] ; then
    export MORE_ARGS=" --restart=always $MORE_ARGS"
fi
echo "[create/single-node] Running in PRODUCTION mode!"

$WTL_SCRIPTS"/helpers/create/commons/single-node-pre.sh"

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
        --link ${WTL_INSTANCE_NAME}-restbase:restbase \
        --add-host=ocg:`docker run -ti --rm debian:8 /sbin/ip route | awk '/default/ { print  $3}'` \
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
