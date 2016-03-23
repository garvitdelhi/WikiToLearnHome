#!/bin/bash

cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

. $WTL_DIR/environments/${WTL_ENV}.sh

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
 echo "wtl-create You need the WTL_INSTANCE_NAME env"
 exit 1
fi

. $WTL_DIR/helpers/create/${WTL_HELPER_CREATE}.sh
