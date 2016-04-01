#!/bin/bash
#WIP

cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
 echo "[lang-foreach] Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

. $WTL_DIR/environments/${WTL_ENV}.sh


echo "[lang-foreach] Finding Languages"
langlist=$(cat $WTL_WORKING_DIR/databases.conf | sed 's/wikitolearn//g' | grep -v shared)

CMD="$@"

echo "[lang-foreach] Found Languages: "$(echo ${langlist[*]})
for lang in $langlist; do
    echo "[lang-foreach] Current lang: $lang"
    docker exec -ti ${WTL_INSTANCE_NAME}-websrv /bin/bash -c "WIKI=$lang.wikitolearn.org php /var/www/WikiToLearn/mediawiki/maintenance/$CMD"
done
