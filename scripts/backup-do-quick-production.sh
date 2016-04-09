#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "backup-do-production.sh" ]] ; then
    echo "Wrong way to execute backup-do-production.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh

if docker inspect wikitolearn-haproxy &> /dev/null ; then
    export WTL_INSTANCE_NAME=$(docker inspect -f '{{index .Config.Labels "WTL_INSTANCE_NAME"}}' wikitolearn-haproxy)
    export WTL_WORKING_DIR=$(docker inspect -f '{{index .Config.Labels "WTL_WORKING_DIR"}}' wikitolearn-haproxy)

    $WTL_SCRIPTS/backup-do-quick.sh
else
    wtl-log backup-do-quick-production.sh 0 MISSING_HA_PROXY "Production backup-do-quick: missing docker wikitolearn-haproxy"
fi
