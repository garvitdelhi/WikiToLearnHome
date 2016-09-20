#!/bin/bash
. ./load-libs.sh

$WTL_SCRIPTS"/helpers/start/commons/single-node-pre.sh"

if ! docker start ${WTL_INSTANCE_NAME}-ocg ; then
    wtl-event START_MIGGING_OCG
    exit 1
fi

$WTL_SCRIPTS"/helpers/start/commons/single-node-websrv.sh"
