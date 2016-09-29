#!/bin/bash
#WIP
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "lang-foreach-php-maintenance.sh" ]] ; then
    echo "Wrong way to execute lang-foreach-php-maintenance.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh


wtl-event LANG_FOREACH_PHP_MAINTENANCE_GET_LANG_LIST
langlist=$(cat $WTL_WORKING_DIR/databases.conf | sed 's/wikitolearn//g' | grep -v shared)

CMD="$@"

langlist_str=""
for l in $langlist
do
  langlist_str=$langlist_str" "$l
done

wtl-event LANG_FOREACH_PHP_MAINTENANCE_LANG_LIST $langlist_str

docker exec ${WTL_INSTANCE_NAME}-websrv chown www-data: /var/www/

for lang in $langlist; do
    wtl-event LANG_FOREACH_PHP_MAINTENANCE_RUN_LANG $lang "$CMD"
    docker exec -ti ${WTL_INSTANCE_NAME}-websrv su -s /bin/sh -c "/bin/bash -c 'WIKI=$lang.wikitolearn.org php /var/www/WikiToLearn/mediawiki/maintenance/$CMD'" www-data
done
