
# run websrv docker linked to other
docker ps | grep ${WTL_INSTANCE_NAME}-websrv &> /dev/null
if [[ $? -ne 0 ]] ; then
 docker ps -a | grep ${WTL_INSTANCE_NAME}-websrv &> /dev/null
 if [[ $? -eq 0 ]] ; then
  docker start ${WTL_INSTANCE_NAME}-websrv
 else
  if [ ! -f configs/secrets/secrets.php ] ; then
   WG_SECRET_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
cat > configs/secrets/secrets.php << EOL
<?php

\$wgSecretKey = "$WG_SECRET_KEY";

\$virtualFactoryUser = "test";
\$virtualFactoryPass = "test";

?>
EOL
  fi

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
  if [[ -d certs/ ]] ; then
   CERTS_MOUNT=" -v "$(pwd)"/certs/:/certs/:ro "
  fi

  docker run -ti $MORE_ARGS -v ${WTL_INSTANCE_NAME}-var-log-apache2:/var/log/apache2 --hostname websrv \
   $CERTS_MOUNT \
   -e USER_UID=$EXT_UID \
   -e USER_GID=$EXT_GID \
   -v $(readlink -f $(dirname $(readlink -f $0))"/.."):/var/www/WikiToLearn/ --name ${WTL_INSTANCE_NAME}-websrv \
   --link ${WTL_INSTANCE_NAME}-mysql:mysql \
   --link ${WTL_INSTANCE_NAME}-memcached:memcached \
   --link ${WTL_INSTANCE_NAME}-ocg:ocg \
   --link ${WTL_INSTANCE_NAME}-mathoid:mathoid \
   --link ${WTL_INSTANCE_NAME}-parsoid:parsoid \
   -d $WTL_DOCKER_WEBSRV

  if [[ "$WTL_RELAY_HOST" != "" ]] ; then
   {
    docker exec ${WTL_INSTANCE_NAME}-websrv sed '/^mailhub/d' /etc/ssmtp/ssmtp.conf
    echo "mailhub=${WTL_RELAY_HOST}" | docker exec -i ${WTL_INSTANCE_NAME}-websrv tee -a /etc/ssmtp/ssmtp.conf
   } &> /dev/null
  fi
 fi
fi

REF_WTL_WEBSRV="docker:${WTL_INSTANCE_NAME}-websrv"
