#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "mw-dumps-import.sh" ]] ; then
    echo "Wrong way to execute mw-dumps-import.sh"
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
    wtl-event MIGGING_WTL_INSTANCE_NAME
    exit 1
fi
if [[ "$1" != "" ]] ; then
   SUBDOM=$1
fi
if test -f "$2" ; then
    FILE=$2
fi
if [[ "$SUBDOM" == "" ]] || [[ "$FILE" == "" ]] ; then
    wtl-event MW_DUMPS_IMPORT_MISSING_ARGS $0
    exit 1
fi
cat $FILE | docker exec -i ${WTL_INSTANCE_NAME}-websrv sh -c "export WIKI='$SUBDOM.$WTL_DOMAIN_NAME' && pwd && cd /var/www/WikiToLearn/mediawiki/maintenance/ && php importDump.php"
