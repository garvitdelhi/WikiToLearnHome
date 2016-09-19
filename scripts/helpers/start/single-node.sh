#!/bin/bash
. ./load-libs.sh

$WTL_SCRIPTS"/helpers/start/commons/single-node-pre.sh"

if ! docker start ${WTL_INSTANCE_NAME}-ocg ; then
    wtl-log scripts/helpers/start/single-node.sh 7 NN "[start/single-node] FATAL ERROR: MISSING OCG"
    exit 1
fi

$WTL_SCRIPTS"/helpers/start/commons/single-node-websrv.sh"
