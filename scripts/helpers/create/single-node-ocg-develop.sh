#!/bin/bash
test -d $WTL_CONFIGS_DIR || mkdir -p $WTL_CONFIGS_DIR
test -d $WTL_CONFIGS_DIR/mysql-users/ || mkdir -p $WTL_CONFIGS_DIR/mysql-users/
test -d $WTL_CONFIGS_DIR/LocalSettings.d/ || mkdir -p $WTL_CONFIGS_DIR/LocalSettings.d/

export MORE_ARGS=" -e WTL_PRODUCTION=$WTL_PRODUCTION"
if [[ "$WTL_PRODUCTION" == "1" ]] ; then
    export MORE_ARGS=" --restart=always $MORE_ARGS"
fi
echo "[create/single-node-ocg-develop] Running in PRODUCTION mode!"

$WTL_SCRIPTS"/helpers/create/commons/single-node-pre.sh"

docker inspect ${WTL_INSTANCE_NAME}-websrv &> /dev/null
if [[ $? -ne 0 ]] ; then

    echo "[create/single-node-ocg-develop] Creating docker ${WTL_INSTANCE_NAME}-websrv"
    docker create -ti $MORE_ARGS  \
        -v ${WTL_VOLUME_DIR}${WTL_INSTANCE_NAME}-var-log-webserver:/var/log/webserver \
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

    echo "[create/single-node-ocg-develop-ocg-develop] Copying certs to websrv"
    if ! docker inspect ${WTL_INSTANCE_NAME}-websrv &> /dev/null ; then
        TMPDIR=`mktemp -d`
        chmod 700 $TMPDIR
        mkdir $TMPDIR/certs
        cp ${WTL_CERTS}/wikitolearn.crt $TMPDIR/certs/websrv.crt
        cp ${WTL_CERTS}/wikitolearn.key $TMPDIR/certs/websrv.key
        if ! docker cp ${TMPDIR}/certs/ ${WTL_INSTANCE_NAME}-websrv:/certs/ ; then
            rm ${TMPDIR} -Rf
            echo "[create/single-node-ocg-develop-ocg-develop] Error: Unable to copy wikitolearn.crt to the webserver"
            exit 1
        fi
        rm ${TMPDIR} -Rf
    fi
fi
