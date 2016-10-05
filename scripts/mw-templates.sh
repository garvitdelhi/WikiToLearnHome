#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "mw-templates.sh" ]] ; then
    echo "Wrong way to execute mw-templates.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh


wtl-event MW_TEMPLATES_GET_LANG_LIST
langlist=$(cat $WTL_WORKING_DIR/databases.conf | sed 's/wikitolearn//g' | grep -v shared)

ACTION="$1"

if [[ "$ACTION" != "export" ]] && [[ "$ACTION" != "import" ]]
then
  wtl-event MW_TEMPLATES_WRONG_ACTION
  exit 1
fi

langlist_str=""
for l in $langlist
do
  langlist_str=$langlist_str" "$l
done

wtl-event MW_TEMPLATES_LANG_LIST $langlist_str
for lang in $langlist; do
    wtl-event MW_TEMPLATES_RUN_LANG $lang "$ACTION"
    if [[ "$ACTION" == "export" ]]
    then
        docker exec -i ${WTL_INSTANCE_NAME}-websrv su -s /bin/sh -c "/bin/bash -c 'WIKI=$lang.$WTL_DOMAIN_NAME php /var/www/WikiToLearn/mediawiki/maintenance/dumpBackup.php --current --filter=namespace:NS_TEMPLATE > /var/www/WikiToLearn/templates/$lang.xml'" www-data
    elif [[ "$ACTION" == "import" ]]
    then
        set +e # FIXME: this command return Segmentation fault after its work. No idea why
        docker exec -i ${WTL_INSTANCE_NAME}-websrv su -s /bin/sh -c "/bin/bash -c 'cat /var/www/WikiToLearn/templates/$lang.xml | WIKI=$lang.$WTL_DOMAIN_NAME php /var/www/WikiToLearn/mediawiki/maintenance/importDump.php --memory-limit:max --debug=true'" www-data
        set -e
    fi
done
