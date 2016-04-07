#!/bin/bash

. ./load-libs.sh

WTL_BACKUP_DIR="$1"

for dbname in $(cat $WTL_WORKING_DIR/databases.conf) ; do
    if [[ $(docker exec -ti wtl-dev-mysql mysql $dbname -e "SHOW TABLES" | wc -l) -eq 0 ]] ; then
        wtl-log helpers/backup-restore/single-node.sh 0 RESTORE_NON_EMPTY_DB "The "$dbname" is not empty"
        exit 1
    fi
done

for dbname in $(cat $WTL_WORKING_DIR/databases.conf) ; do
    echo "[restore-backup/single-node] Restore for "$dbname
    cat $WTL_BACKUP_DIR"/"$dbname".struct.sql" | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql $dbname
    cat $WTL_BACKUP_DIR"/"$dbname".data.sql"   | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql $dbname
done
rsync -a --stats --delete $WTL_BACKUP_DIR"/images/" $WTL_WORKING_DIR"/mediawiki/images/"
