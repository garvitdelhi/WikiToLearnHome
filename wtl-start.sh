#!/bin/bash

#cd to current script folder
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
    echo "[wtl-start] Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh

. $WTL_DIR/environments/${WTL_ENV}.sh

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
    echo "[wtl-start] Error: You need the WTL_INSTANCE_NAME env variable"
    exit 1
fi

. $WTL_DIR/helpers/start/${WTL_HELPER_START}.sh
