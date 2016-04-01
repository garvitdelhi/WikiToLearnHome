#!/bin/bash
#WIP

cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

./lang-foreach-php-maintenance.sh update.php --conf=/var/www/WikiToLearn/mediawiki/LocalSettings.php --quick --doShared
