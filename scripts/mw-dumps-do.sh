#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "mw-dumps-do.sh" ]] ; then
    echo "Wrong way to execute mw-dumps-do.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
    wtl-log mw-dumps-do.sh 0 MIGGING_WTL_INSTANCE_NAME "You need the WTL_INSTANCE_NAME env"
    exit 1
fi
for db in $(docker exec -ti ${WTL_INSTANCE_NAME}-mysql mysql -e "SHOW DATABASES" | grep wikitolearn | awk '{ print $2 }') ; do
    SUBDOM=$(echo $db | sed 's/wikitolearn//g')
    wtl-log mw-dumps-do.sh 0 DUMPING "Dump for $SUBDOM.$WTL_DOMAIN_NAME"
    docker exec -ti ${WTL_INSTANCE_NAME}-websrv sh -c "export WIKI='$SUBDOM.$WTL_DOMAIN_NAME' && pwd && cd /var/www/WikiToLearn/mediawiki/maintenance/ && php dumpBackup.php --full" > $WTL_MW_DUMPS"/"$SUBDOM.xml
done
