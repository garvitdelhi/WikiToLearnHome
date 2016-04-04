#!/bin/bash
echo "[environment] Using 'base' environment"

if [[ "$WTL_WORKING_DIR" == "" ]] ; then
    export WTL_WORKING_DIR=$WTL_REPO_DIR
fi

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
    export WTL_INSTANCE_NAME="wtl-dev"
fi

if [[ -f $WTL_WORKING_DIR/docker-images.conf ]] ; then
    . $WTL_WORKING_DIR/docker-images.conf
fi

export WTL_MATHOID_NUM_WORKERS=1

export WTL_HELPER_CREATE="single-node"
export WTL_HELPER_START="single-node"
export WTL_HELPER_RESTORE_BACKUP="single-node"
export WTL_HELPER_DO_BACKUP="single-node"
export WTL_HELPER_MAKE_READONLY="single-node"
export WTL_HELPER_MAKE_READWRITE="single-node"
