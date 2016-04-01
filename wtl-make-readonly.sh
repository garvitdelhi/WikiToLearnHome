#!/bin/bash

cd $(dirname $(realpath $0))

if [[ ! -f "wtl-create.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh

. $WTL_DIR/environments/${WTL_ENV}.sh
. $WTL_DIR/helpers/make-readonly/${WTL_HELPER_MAKE_READONLY}.sh
