#!/bin/bash

$WTL_SCRIPTS"/helpers/start/commons/single-node-pre.sh"

if ! docker start ${WTL_INSTANCE_NAME}-ocg ; then
    echo "[start/single-node] FATAL ERROR: MISSING OCG"
    exit 1
fi

$WTL_SCRIPTS"/helpers/start/commons/single-node-websrv.sh"
