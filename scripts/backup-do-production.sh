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

. $WTL_SCRIPTS/load-productoin-instance.sh
. $WTL_SCRIPTS/environments/${WTL_ENV}.sh

$WTL_SCRIPTS/backup-do.sh
