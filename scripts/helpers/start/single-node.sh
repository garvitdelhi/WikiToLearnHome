#!/bin/bash

$WTL_SCRIPTS"/helpers/start/commons/single-node-pre.sh"

docker start ${WTL_INSTANCE_NAME}-ocg
if [[ $? -ne 0 ]] ; then
    echo "[start/single-node] FATAL ERROR: MISSING OCG"
    exit 1
fi

$WTL_SCRIPTS"/helpers/start/commons/single-node-websrv.sh"

