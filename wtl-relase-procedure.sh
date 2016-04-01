#!/bin/bash
cd $(dirname $(realpath $0))

if [[ ! -f "wtl-relase-procedure.sh" ]] ; then
    echo "[WTL RELASE] Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh

cd $WTL_REPO_DIR
GIT_ID_CURRENT=$(git log -n 1 --format="%H")
cd $(dirname $(realpath $0))

$WTL_DIR/wtl-download-code.sh

cd $WTL_REPO_DIR
GIT_ID_NEW=$(git log -n 1 --format="%H")
cd $(dirname $(realpath $0))

if [[ "$GIT_ID_CURRENT" != "$GIT_ID_NEW" ]] ; then
    echo "New running"
    $WTL_DIR/create-running.sh $GIT_ID_NEW

    export NEW_WTL_INSTANCE_NAME="wtl-"${GIT_ID_NEW:0:8}
    export NEW_WTL_WORKING_DIR=${WTL_RUNNING}"/"${GIT_ID_NEW}

    docker inspect wikitolearn-haproxy &> /dev/null && {
        export OLD_WTL_INSTANCE_NAME=$(docker inspect -f '{{index .Config.Labels "WTL_INSTANCE_NAME"}}' wikitolearn-haproxy)
        export OLD_WTL_WORKING_DIR=$(docker inspect -f '{{index .Config.Labels "WTL_WORKING_DIR"}}' wikitolearn-haproxy)
    }

    export WTL_INSTANCE_NAME=$NEW_WTL_INSTANCE_NAME
    export WTL_WORKING_DIR=$NEW_WTL_WORKING_DIR
    $WTL_DIR/wtl-create.sh
    $WTL_DIR/wtl-start.sh

    docker inspect wikitolearn-haproxy &> /dev/null && {
        export WTL_INSTANCE_NAME=$OLD_WTL_INSTANCE_NAME
        export WTL_WORKING_DIR=$OLD_WTL_WORKING_DIR
        $WTL_DIR/wtl-make-readonly.sh "This wiki is currently being upgraded to a newer software version."
        $WTL_DIR/wtl-do-backup.sh
        BACKUPDIR=$WTL_REPO_DIR"/DeveloperDump/" # FIXME
    }
    docker inspect wikitolearn-haproxy &> /dev/null || {
        BACKUPDIR=$WTL_REPO_DIR"/DeveloperDump/"
    }

    export WTL_INSTANCE_NAME=$NEW_WTL_INSTANCE_NAME
    export WTL_WORKING_DIR=$NEW_WTL_WORKING_DIR
    $WTL_DIR/wtl-restore-backup.sh "$BACKUPDIR"
    $WTL_DIR/wtl-update-db.sh
    $WTL_DIR/wtl-use-instance.sh
fi
