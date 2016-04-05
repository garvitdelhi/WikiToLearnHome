#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "copy-last-backup-to-devdump.sh" ]] ; then
    echo "Wrong way to execute copy-last-backup-to-devdump.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh

LAST_BACKUP=$(ls -r $WTL_BACKUPS | head -1)

if [[ "$LAST_BACKUP" != "" ]] ; then
    rsync -a --stats --delete $WTL_BACKUPS"/"$LAST_BACKUP"/" ${WTL_REPO_DIR}"/DeveloperDump/"
else
    wtl-log copy-last-backup-to-devdump.sh 0 BACKUP_NOT_FOUND "No backup founds"
fi
