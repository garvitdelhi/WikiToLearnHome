#!/bin/bash
cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
 echo "[mrsn] Error changing directory"
 exit 1
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
test -d $WTL_CONFIGS_DIR/secrets/ || mkdir -p $WTL_CONFIGS_DIR/secrets/


export MORE_ARGS=" -e WTL_PRODUCTION=$WTL_PRODUCTION"
if [[ "$WTL_PRODUCTION" == "1" ]] ; then
    export MORE_ARGS=" --restart=always $MORE_ARGS"
    echo "[mrsn] Running in PRODUCTION mode!"
fi


#Control the existance of docker instances and create them if they are not existing
docker inspect ${WTL_INSTANCE_NAME}-parsoid &> /dev/null
if [[ $? -ne 0 ]] ; then
    echo "[mrsn] Creating docker ${WTL_INSTANCE_NAME}-parsoid"
    docker create -ti $MORE_ARGS --hostname parsoid --name ${WTL_INSTANCE_NAME}-parsoid $WTL_DOCKER_PARSOID
fi

if [[ "$WTL_MATHOID_NUM_WORKERS" == "" ]] ; then
    export WTL_MATHOID_NUM_WORKERS=1
fi

docker inspect ${WTL_INSTANCE_NAME}-mathoid &> /dev/null
if [[ $? -ne 0 ]] ; then
    echo "[mrsn] Creating docker ${WTL_INSTANCE_NAME}-mathoid with $WTL_MATHOID_NUM_WORKERS workers"
    docker create -ti $MORE_ARGS --hostname mathoid --name ${WTL_INSTANCE_NAME}-mathoid -e NUM_WORKERS=$MATHOID_NUM_WORKERS $WTL_DOCKER_MATHOID
fi

docker inspect ${WTL_INSTANCE_NAME}-memcached &> /dev/null
if [[ $? -ne 0 ]] ; then
    echo "[mrsn] Creating docker ${WTL_INSTANCE_NAME}-memcached"
    docker create -ti $MORE_ARGS --hostname memcached --name ${WTL_INSTANCE_NAME}-memcached $WTL_DOCKER_MEMCACHED
fi

docker inspect ${WTL_INSTANCE_NAME}-mysql &> /dev/null
if [[ $? -ne 0 ]] ; then
    ROOT_PWD=$(echo $RANDOM$RANDOM$(date +%s) | sha256sum | base64 | head -c 32 )
    
    echo "[mrsn] Creating docker ${WTL_INSTANCE_NAME}-mysql"
    docker create -ti $MORE_ARGS -v ${WTL_INSTANCE_NAME}-var-lib-mysql:/var/lib/mysql --hostname mysql --name ${WTL_INSTANCE_NAME}-mysql -e MYSQL_ROOT_PASSWORD=$ROOT_PWD $WTL_DOCKER_MYSQL
    
    echo "[client]" > $WTL_CONFIGS_DIR/mysql-root-password.cnf
    echo "user=root" >> $WTL_CONFIGS_DIR/mysql-root-password.cnf
    echo "password=$ROOT_PWD" >> $WTL_CONFIGS_DIR/mysql-root-password.cnf

    echo "[mrsn] mysql root password: $ROOT_PWD"

    docker cp $WTL_CONFIGS_DIR/mysql-root-password.cnf ${WTL_INSTANCE_NAME}-mysql:/root/.my.cnf
fi
    
#docker inspect ${WTL_INSTANCE_NAME}-ocg &> /dev/null
#if [[ $? -ne 0 ]] ; then
#    docker create -ti $MORE_ARGS -v wikitolearn-ocg:/tmp/ocg/ocg-output/ --hostname ocg --link ${WTL_INSTANCE_NAME}-parsoid:parsoid --name ${WTL_INSTANCE_NAME}-ocg $WTL_DOCKER_OCG
#fi

docker inspect ${WTL_INSTANCE_NAME}-websrv &> /dev/null
if [[ $? -ne 0 ]] ; then  

    if [ ! -f configs/secrets/secrets.php ] ; then
        echo "[mrsn] 'secrets.php' not found, creating now"

        WG_SECRET_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
        
        cat > $WTL_CONFIGS_DIR/secrets/secrets.php << EOL
<?php

\$wgSecretKey = "$WG_SECRET_KEY";

\$virtualFactoryUser = "test";
\$virtualFactoryPass = "test";

?>
EOL
    fi #end secrets.php if

    EXT_UID=$(id -u)
    EXT_GID=$(id -g)
    if [[ "$EXT_UID" == "0" ]] ; then
        EXT_UID=1000
    fi
    if [[ "$EXT_GID" == "0" ]] ; then
        EXT_GID=1000
    fi
    MAIL_SRV_LINK=""

    CERTS_MOUNT=""
    if [[ -d $WTL_CERTS ]] ; then
        echo "[mrsn] Found certificates directory"

        CERTS_MOUNT=" -v $WTL_CERTS:/certs/:ro"
    fi

    echo "[mrsn] Creating docker ${WTL_INSTANCE_NAME}-websrv"

    docker create -ti $MORE_ARGS  \
        -v ${WTL_INSTANCE_NAME}-var-log-apache2:/var/log/apache2 \
        --hostname websrv \
        --name ${WTL_INSTANCE_NAME}-websrv \
        $CERTS_MOUNT \
        -e USER_UID=$EXT_UID \
        -e USER_GID=$EXT_GID \
        -v $(readlink -f $(dirname $(readlink -f $0))"/.."):/var/www/WikiToLearn/ --name ${WTL_INSTANCE_NAME}-websrv \
        --link ${WTL_INSTANCE_NAME}-mysql:mysql \
        --link ${WTL_INSTANCE_NAME}-memcached:memcached \
        --link ${WTL_INSTANCE_NAME}-mathoid:mathoid \
        --link ${WTL_INSTANCE_NAME}-parsoid:parsoid \
        $WTL_DOCKER_WEBSRV

        #--link ${WTL_INSTANCE_NAME}-ocg:ocg \
    : 'if [[ "$WTL_RELAY_HOST" != "" ]] ; then
        {
        docker exec ${WTL_INSTANCE_NAME}-websrv sed '/^mailhub/d' /etc/ssmtp/ssmtp.conf
        echo "mailhub=${WTL_RELAY_HOST}" | docker exec -i ${WTL_INSTANCE_NAME}-websrv tee -a /etc/ssmtp/ssmtp.conf
        } &> /dev/null
    fi'
fi

echo "[mrsn] Copying certs to websrv"
docker inspect ${WTL_INSTANCE_NAME}-websrv &> /dev/null
if [[ $? -ne 0 ]] ; then      
    docker cp ${WTL_CERTS}/wikitolearn.crt ${WTL_INSTANCE_NAME}-websrv:/etc/ssl/certs/apache.crt
    if [[ $? -ne 0 ]] ; then
        echo = "unable to copy wikitolearn.crt to the webserver"
        exit 1
    fi
    docker cp ${WTL_CERTS}/wikitolearn.key ${WTL_INSTANCE_NAME}-websrv:/etc/ssl/private/apache.key
    if [[ $? -ne 0 ]] ; then
        echo = "unable to copy wikitolearn.key to the webserver"
        exit 1
    fi
fi 
