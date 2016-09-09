#!/bin/bash
. ./load-libs.sh

BACKUP_DIR=$WTL_BACKUPS"/"$(date +'%Y_%m_%d__%H_%M_%S')

test -d $BACKUP_DIR || mkdir $BACKUP_DIR

wtl-log scripts/helpers/backup-do/single-node.sh 7 BACKUP_STARTED "Started backup for "${WTL_INSTANCE_NAME}

rsync -a --stats --delete $WTL_WORKING_DIR"/mediawiki/images/" ${BACKUP_DIR}"/images/"

wtl-log scripts/helpers/backup-do/single-node.sh 7 BACKUP_RO "Instance "${WTL_INSTANCE_NAME}" read only"

$WTL_SCRIPTS/make-readonly.sh "This wiki is currently being backed up"

for db in $(docker exec -ti ${WTL_INSTANCE_NAME}-mysql mysql -e "SHOW DATABASES" | grep wikitolearn | awk '{ print $2 }') ; do
 wtl-log scripts/helpers/backup-do/single-node.sh 7 BACKUP_DB "Backup "$db
 BACKUP_FILE=$BACKUP_DIR"/"$db
 BACKUP_FILE_STRUCT=$BACKUP_FILE".struct.sql"
 BACKUP_FILE_DATA=$BACKUP_FILE".data.sql"

 docker exec -ti ${WTL_INSTANCE_NAME}-mysql mysqldump --skip-add-drop-table --skip-comments -d $db > $BACKUP_FILE_STRUCT
 sed -i 's/CREATE TABLE/CREATE TABLE IF NOT EXISTS/g' $BACKUP_FILE_STRUCT

 docker exec -ti ${WTL_INSTANCE_NAME}-mysql mysqldump --no-create-info $db    > $BACKUP_FILE_DATA
done

rsync -a --stats --delete $WTL_WORKING_DIR"/mediawiki/images/" ${BACKUP_DIR}"/images/"

$WTL_SCRIPTS/make-readwrite.sh "This wiki is currently being backed up"

wtl-log scripts/helpers/backup-do/single-node.sh 7 BACKUP_FINISHED "Backup for "${WTL_INSTANCE_NAME}" finished"
