#!/bin/bash
. ./load-libs.sh

WTL_BACKUP_DIR="$1"

for dbname in $(cat $WTL_WORKING_DIR/databases.conf) ; do
    TABLE_COUNT=$(docker exec -ti ${WTL_INSTANCE_NAME}-mysql mysql $dbname -e "SHOW TABLES" | wc -l)
    if [[ $TABLE_COUNT -ne 0 ]] ; then
        wtl-event RESTORE_NON_EMPTY_DB $dbname $TABLE_COUNT
        exit 1
    fi
done

for dbname in $(cat $WTL_WORKING_DIR/databases.conf) ; do
    if test -f $WTL_BACKUP_DIR"/"$dbname".struct.sql"
    then
        wtl-event RESTORE_DB $dbname
        cat $WTL_BACKUP_DIR"/"$dbname".struct.sql" | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql $dbname
        if test -f $WTL_BACKUP_DIR"/"$dbname".data.sql"
        then
            cat $WTL_BACKUP_DIR"/"$dbname".data.sql"   | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql $dbname
        fi
    else
        if test -f $WTL_REPO_DIR"/DeveloperDump/"$dbname".struct.sql"
        then
            wtl-event RESTORE_DB_DEVELOPER_DUMP $dbname
            cat $WTL_REPO_DIR"/DeveloperDump/"$dbname".struct.sql" | docker exec -i ${WTL_INSTANCE_NAME}-mysql mysql $dbname
        else
            wtl-event RESTORE_DB_MISSING_DUMP $dbname
        fi
    fi
done
rsync -a --stats --delete $WTL_BACKUP_DIR"/images/" $WTL_WORKING_DIR"/mediawiki/images/"
