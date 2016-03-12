#!/bin/bash

cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
 echo "You need the WTL_INSTANCE_NAME env"
 exit 1
fi

. $WTL_DIR/environments/${WTL_ENV}.sh
. $WTL_DIR/helpers/restore-backup/${WTL_HELPER_RESTORE_BACKUP}.sh
