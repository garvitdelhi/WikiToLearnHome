#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "start.sh" ]] ; then
    echo "Wrong way to execute start.sh"
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
    wtl-event START_MISSING_INSTANCE_NAME
    exit 1
fi

$WTL_SCRIPTS/helpers/start/${WTL_HELPER_START}.sh
