#!/bin/bash
#WIP

cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

if [[ "$1" == "--init-db" ]] ; then
    WTL_INIT_DB=1
fi

if [[ "$WTL_INIT_DB" == "1" ]] ; then
    . ./lang-foreach-php-maintenance.sh sql.php --debug --conf $WTL_REPO_DIR/mediawiki/LocalSettings.php $WTL_REPO_DIR/empty-wikitolearn.sql
    WIKI=it.wikitolearn.org php $WTL_REPO_DIR/mediawiki/maintenance/sql.php --debug --conf SharedLocalSettings.php $WTL_REPO_DIR/sharedwikitolearn.sql
fi

# For every language, update the database
. ./lang-foreach-php-maintenance.sh update.php --conf=$WTL_REPO_DIR/mediawiki/LocalSettings.php --quick --doShared
