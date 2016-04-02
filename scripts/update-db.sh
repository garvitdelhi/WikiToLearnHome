#!/bin/bash
#WIP
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "update-db.sh" ]] ; then
    echo "Wrong way to execute update-db.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh

$WTL_SCRIPTS/lang-foreach-php-maintenance.sh update.php --conf=/var/www/WikiToLearn/mediawiki/LocalSettings.php --quick --doShared
