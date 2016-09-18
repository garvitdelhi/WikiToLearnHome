#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "backup-auto-delete.sh" ]] ; then
    echo "Wrong way to execute backup-auto-delete.sh"
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
    wtl-event MIGGING_WTL_INSTANCE_NAME
    exit 1
fi

if [[ "$WTL_BACKUPS_MAX_NUM" == "" ]] ; then
    export WTL_BACKUPS_MAX_NUM=5
fi

while [[ $(ls $WTL_BACKUPS | grep -v StaticBackup | wc -l) -gt $WTL_BACKUPS_MAX_NUM ]] ; do
    BACKUP_TO_DELETE=`ls -tr $WTL_BACKUPS | grep -v StaticBackup | head -1`
    wtl-event BACKUP_AUTO_DELETE_DO_FOR $BACKUP_TO_DELETE
    rm -Rf $WTL_BACKUPS"/"$BACKUP_TO_DELETE"/"
done
