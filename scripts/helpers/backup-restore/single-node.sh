#!/bin/bash
. ./load-libs.sh

WTL_BACKUP_DIR="$1"

for dbname in $(cat $WTL_WORKING_DIR/databases.conf) ; do
    TABLE_COUNT=$(docker exec -ti ${WTL_INSTANCE_NAME}-mysql mysql $dbname -e "SHOW TABLES" | wc -l)
    if [[ $TABLE_COUNT -ne 0 ]] ; then
        wtl-log scripts/helpers/backup-restore/single-node.sh 0 RESTORE_NON_EMPTY_DB "The "$dbname" is not empty ("$TABLE_COUNT" tables)"
        exit 1
    fi
done

for dbname in $(cat $WTL_WORKING_DIR/databases.conf) ; do
    if test -f $WTL_BACKUP_DIR"/"$dbname".struct.sql"
    then
        wtl-log scripts/helpers/backup-restore/single-node.sh 0 RESTORE_DB "Restore for $dbname"
        cat $WTL_BACKUP_DIR"/"$dbname".struct.sql" | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql $dbname
        if test -f $WTL_BACKUP_DIR"/"$dbname".data.sql"
        then
            cat $WTL_BACKUP_DIR"/"$dbname".data.sql"   | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql $dbname
        fi
    else
        if test -f $WTL_REPO_DIR"/DeveloperDump/"$dbname".struct.sql"
        then
            wtl-log scripts/helpers/backup-restore/single-node.sh 0 RESTORE_DB_DEVELOPER_DUMP "Restore for $dbname from DeveloperDump"
            cat $WTL_REPO_DIR"/DeveloperDump/"$dbname".struct.sql" | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql $dbname
        else
            wtl-log scripts/helpers/backup-restore/single-node.sh 0 RESTORE_DB_MISSING_DUMP "Missing dump for $dbname"
        fi
    fi
done
rsync -a --stats --delete $WTL_BACKUP_DIR"/images/" $WTL_WORKING_DIR"/mediawiki/images/"
