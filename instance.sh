#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e

cd $(dirname $(realpath $0))

. ./load-libs.sh

#if [[ ! -f $WTL_CACHE"/wtl-home-last-auto-update" ]] || [[ $(($(date +%s)-$(date +%s -r $WTL_CACHE"/wtl-home-last-auto-update"))) -gt 3300 ]] ; then
#    echo "3600 sec from last WikiToLearn Home updates check..."
#    $WTL_SCRIPTS/update-home.sh
#    touch $WTL_CACHE"/wtl-home-last-auto-update"
#    exit
#fi

if [[ $# -eq 0 ]] ; then
    $0 help
    exit $?
fi

case $1 in
    first-run)
        $WTL_SCRIPTS/download-all.sh
        $WTL_SCRIPTS/download-mediawiki-extensions.sh
        $WTL_SCRIPTS/create.sh
        $WTL_SCRIPTS/start.sh
        $WTL_SCRIPTS/backup-restore.sh $WTL_REPO_DIR/DeveloperDump/
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/use-instance.sh
        $WTL_SCRIPTS/update-db.sh
    ;;
    create)
        $WTL_SCRIPTS/create.sh
    ;;
    start)
        $WTL_SCRIPTS/start.sh
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/use-instance.sh
        $WTL_SCRIPTS/fix-hosts.sh
    ;;
    stop)
        $WTL_SCRIPTS/stop.sh
        $WTL_SCRIPTS/unuse-instance.sh
    ;;
    delete)
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/stop.sh
        $WTL_SCRIPTS/delete.sh
    ;;
    delete-full)
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/stop.sh
        $WTL_SCRIPTS/delete.sh
        $WTL_SCRIPTS/delete-volumes.sh
    ;;
    delete-volumes)
        $WTL_SCRIPTS/delete-volumes.sh
    ;;
    update-docker-container)
        $WTL_SCRIPTS/pull-images.sh
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/stop.sh
        $WTL_SCRIPTS/delete.sh
        $WTL_SCRIPTS/create.sh
        $WTL_SCRIPTS/start.sh
        $WTL_SCRIPTS/use-instance.sh
        $WTL_SCRIPTS/fix-hosts.sh
    ;;
    devdump-import)
        $WTL_SCRIPTS/backup-restore.sh $WTL_REPO_DIR/DeveloperDump/
        $WTL_SCRIPTS/update-db.sh
    ;;
    download)
        $WTL_SCRIPTS/download-code.sh
        $WTL_SCRIPTS/download-mediawiki-extensions.sh
    ;;
    fix-hosts)
        $WTL_SCRIPTS/fix-hosts.sh
    ;;
    update-home)
        $WTL_SCRIPTS/update-home.sh
    ;;
    staging)
        $WTL_SCRIPTS/relase-procedure.sh
        $WTL_SCRIPTS/backup-auto-delete.sh
        $WTL_SCRIPTS/unused-instance-stop-delete.sh
    ;;
    help)
        echo "No help yet, sorry"
    ;;
    *)
        echo "Command not found ($@)"
        exit
    ;;
esac
