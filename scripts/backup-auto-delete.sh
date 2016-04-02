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

. ./load-wikitolearn.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
 echo "You need the WTL_INSTANCE_NAME env"
 exit 1
fi



while [[ $(ls $WTL_BACKUPS | grep -v StaticBackup | wc -l) -gt 1 ]] ; do
    echo "Deleting the backup: "`ls -tr $WTL_BACKUPS | grep -v StaticBackup | head -1`
    rm -Rf $WTL_BACKUPS"/"`ls -tr $WTL_BACKUPS | grep -v StaticBackup | head -1`"/"
done

