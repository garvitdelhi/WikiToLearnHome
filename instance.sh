#!/bin/bash
cd $(dirname $(realpath $0))

. ./load-wikitolearn.sh

case $1 in
    first-run)
        $WTL_SCRIPTS/download-all.sh
        $WTL_SCRIPTS/create.sh
        $WTL_SCRIPTS/start.sh
        $WTL_SCRIPTS/backup-restore.sh $WTL_REPO_DIR/DeveloperDump/
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/use-instance.sh
        $WTL_SCRIPTS/update-db.sh
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
        $WTL_SCRIPTS/stop.sh
        $WTL_SCRIPTS/delete.sh
        $WTL_SCRIPTS/unuse-instance.sh
    ;;
    download)
        $WTL_SCRIPTS/download-code.sh
    ;;
    update-home)
    ;;
        $WTL_SCRIPTS/update-home.sh
    ;;
esac
