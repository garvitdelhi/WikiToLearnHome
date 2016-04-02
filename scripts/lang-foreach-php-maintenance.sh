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


echo "[lang-foreach] Finding Languages"
langlist=$(cat $WTL_WORKING_DIR/databases.conf | sed 's/wikitolearn//g' | grep -v shared)

CMD="$@"

echo "[lang-foreach] Found Languages: "$(echo ${langlist[*]})
for lang in $langlist; do
    echo "[lang-foreach] Current lang: $lang"
    docker exec -ti ${WTL_INSTANCE_NAME}-websrv /bin/bash -c "WIKI=$lang.wikitolearn.org php /var/www/WikiToLearn/mediawiki/maintenance/$CMD"
done
