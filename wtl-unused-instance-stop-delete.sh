#!/bin/bash
cd $(dirname $(realpath $0))

if [[ ! -f "wtl-relase-procedure.sh" ]] ; then
    echo "[WTL RELASE] Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh

for instance in $(./list-instances.sh | grep -v $(docker inspect -f '{{index .Config.Labels "WTL_INSTANCE_NAME"}}' wikitolearn-haproxy | awk -F'-' '{ print $2 }'))
do
    if [[ $(ls $WTL_RUNNING | grep ^$instance | wc -l) -eq 1 ]] ; then
        DIR_NAME=`ls $WTL_RUNNING | grep ^$instance`
        export WTL_INSTANCE_NAME="wtl-"${DIR_NAME:0:8}
        export WTL_WORKING_DIR=$WTL_RUNNING"/"$DIR_NAME
        echo $WTL_INSTANCE_NAME
        ./wtl-stop.sh
        ./wtl-delete.sh
        if [[ -d $WTL_WORKING_DIR ]] ; then
            rm -Rf $WTL_WORKING_DIR
        fi
    fi
done
