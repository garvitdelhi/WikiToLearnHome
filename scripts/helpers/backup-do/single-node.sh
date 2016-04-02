#!/bin/bash

BACKUP_DIR=$WTL_BACKUPS"/"$(date +'%Y_%m_%d__%H_%M_%S')

echo $BACKUP_DIR

test -d $BACKUP_DIR || mkdir $BACKUP_DIR

rsync --stats -av $WTL_WORKING_DIR"/mediawiki/images/" ${BACKUP_DIR}"/images/"

$WTL_DIR/wtl-make-readonly.sh "This wiki is currently being backed up"

for db in $(docker exec -ti ${WTL_INSTANCE_NAME}-mysql mysql -e "SHOW DATABASES" | grep wikitolearn | awk '{ print $2 }') ; do
 echo "Backup "$db
 BACKUP_FILE=$BACKUP_DIR"/"$db
 BACKUP_FILE_STRUCT=$BACKUP_FILE".struct.sql"
 BACKUP_FILE_DATA=$BACKUP_FILE".data.sql"

 docker exec -ti ${WTL_INSTANCE_NAME}-mysql mysqldump --skip-add-drop-table --skip-comments --compact -d $db > $BACKUP_FILE_STRUCT
 sed -i 's/CREATE TABLE/CREATE TABLE IF NOT EXISTS/g' $BACKUP_FILE_STRUCT

 docker exec -ti ${WTL_INSTANCE_NAME}-mysql mysqldump --no-create-info      --skip-comments --compact $db    > $BACKUP_FILE_DATA
done

rsync --stats -av $WTL_WORKING_DIR"/mediawiki/images/" ${BACKUP_DIR}"/images/"

$WTL_DIR/wtl-make-readwrite.sh "This wiki is currently being backed up"
