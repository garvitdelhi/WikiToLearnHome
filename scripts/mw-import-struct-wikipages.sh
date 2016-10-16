#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "mw-import-struct-wikipages.sh" ]] ; then
    echo "Wrong way to execute mw-import-struct-wikipages.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh


wtl-event MW_STRUCT_PAGES_GET_LANG_LIST
langlist=$(cat $WTL_WORKING_DIR/databases.conf | sed 's/wikitolearn//g' | grep -v shared)

langlist_str=""
for l in $langlist
do
  langlist_str=$langlist_str" "$l
done

wtl-event MW_STRUCT_PAGES_LANG_LIST $langlist_str
for lang in $langlist; do
    wtl-event MW_STRUCT_PAGES_RUN_LANG $lang

    if test -d $WTL_WORKING_DIR/struct-wikipages/ALL_LANGUAGES/ && [[ $(ls $WTL_WORKING_DIR/struct-wikipages/ALL_LANGUAGES/  | wc -l) -gt 0 ]]
    then
        docker exec -i ${WTL_INSTANCE_NAME}-websrv su -s /bin/sh -c \
            "/bin/bash -c 'WIKI=$lang.$WTL_DOMAIN_NAME php /var/www/WikiToLearn/mediawiki/maintenance/importTextFiles.php --bot --rc --overwrite /var/www/WikiToLearn/struct-wikipages/ALL_LANGUAGES/*'" www-data
    fi

    if test -d $WTL_WORKING_DIR/struct-wikipages/$lang/ && [[ $(ls $WTL_WORKING_DIR/struct-wikipages/$lang/  | wc -l) -gt 0 ]]
    then
        docker exec -i ${WTL_INSTANCE_NAME}-websrv su -s /bin/sh -c \
            "/bin/bash -c 'WIKI=$lang.$WTL_DOMAIN_NAME php /var/www/WikiToLearn/mediawiki/maintenance/importTextFiles.php --bot --rc --overwrite /var/www/WikiToLearn/struct-wikipages/$lang/*'" www-data
    fi
done
