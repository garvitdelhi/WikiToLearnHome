#!/bin/bash

WTL_BACKUP_DIR="$1"

for dbname in $(cat $WTL_WORKING_DIR/databases.conf) ; do
    echo "[restore-backup/single-node] Restore for "$dbname
    cat $WTL_BACKUP_DIR"/"$dbname".struct.sql" | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql $dbname
    cat $WTL_BACKUP_DIR"/"$dbname".data.sql"   | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql $dbname
done
rsync --stats -av $WTL_BACKUP_DIR"/images/" $WTL_WORKING_DIR"/mediawiki/images/"
