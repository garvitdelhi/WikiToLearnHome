#!/bin/bash

# run mysql and init
docker ps | grep ${W2L_INSTANCE_NAME}-mysql &> /dev/null
if [[ $? -ne 0 ]] ; then
 docker ps -a | grep ${W2L_INSTANCE_NAME}-mysql &> /dev/null
 if [[ $? -eq 0 ]] ; then
  docker start ${W2L_INSTANCE_NAME}-mysql
 else
  test -d $W2L_CONFIGS_DIR/secrets/ || mkdir -p $W2L_CONFIGS_DIR/secrets/
  ROOT_PWD=$(echo $RANDOM$RANDOM$(date +%s) | sha256sum | base64 | head -c 32 )
  if [[ "$W2L_DOCKER_MOUNT_DIRS" == "1" ]] ; then
   MOUNT_DIR="-v '$W2L_DOCKER_MYSQL_DATA_PATH':/var/lib/mysql"
  else
   MOUNT_DIR=""
  fi
  docker run -ti $MORE_ARGS --hostname mysql.$W2L_DOMAIN_NAME --name ${W2L_INSTANCE_NAME}-mysql -e MYSQL_ROOT_PASSWORD=$ROOT_PWD -d $W2L_DOCKER_MYSQL
  echo "Waiting mysql init..."
  false
  while [[ $? -ne 0 ]] ; do
   sleep 1
   docker logs ${W2L_INSTANCE_NAME}-mysql | grep "MySQL init process done. Ready for start up." &> /dev/null
  done

  {
   echo "[client]"
   echo "user=root"
   echo "password=$ROOT_PWD"
  } | docker exec -i ${W2L_INSTANCE_NAME}-mysql tee /root/.my.cnf

  echo "Attesa mysql online..."
  {
  while ! docker exec -i ${W2L_INSTANCE_NAME}-mysql mysql -e "SHOW DATABASES" ; do
   sleep 1
  done
  } &> /dev/null

  {
   # to add a domain you must add the line in apache config file apache2/common/WikiToLearn.conf in WebSrv repo
   echo "CREATE DATABASE IF NOT EXISTS dewikitolearn;"
   echo "CREATE DATABASE IF NOT EXISTS enwikitolearn;"
   echo "CREATE DATABASE IF NOT EXISTS eswikitolearn;"
   echo "CREATE DATABASE IF NOT EXISTS frwikitolearn;"
   echo "CREATE DATABASE IF NOT EXISTS itwikitolearn;"
   echo "CREATE DATABASE IF NOT EXISTS ptwikitolearn;"
   echo "CREATE DATABASE IF NOT EXISTS svwikitolearn;"
   echo "CREATE DATABASE IF NOT EXISTS metawikitolearn;"
   echo "CREATE DATABASE IF NOT EXISTS poolwikitolearn;"
   echo "CREATE DATABASE IF NOT EXISTS sharedwikitolearn;"
  } | docker exec -i ${W2L_INSTANCE_NAME}-mysql mysql

  docker exec -i ${W2L_INSTANCE_NAME}-mysql mysql -e "show databases like '%wiki%';" | grep wikitolearn | while read db; do
   pass=$(echo $RANDOM$RANDOM$(date +%s) | sha256sum | base64 | head -c 32)
   user=${db::-11}
   {
    echo "GRANT ALL PRIVILEGES ON * . * TO '"$user"'@'%' IDENTIFIED BY '"$pass"';"
   } | docker exec -i ${W2L_INSTANCE_NAME}-mysql mysql

   {
    echo "<?php"
    echo "\$wgDBuser='"$user"';"
    echo "\$wgDBpassword='"$pass"';"
    echo "\$wgDBname='"$db"';"
    echo "?>"
   } > $W2L_CONFIGS_DIR/secrets/$db.php

  done
 fi
fi

REF_W2L_MYSQL="--link ${W2L_INSTANCE_NAME}-mysql:mysql"
