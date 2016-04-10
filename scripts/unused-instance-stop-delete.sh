#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "unused-instance-stop-delete.sh" ]] ; then
    echo "Wrong way to execute unused-instance-stop-delete.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

if docker inspect wikitolearn-haproxy &> /dev/null ; then
    INSTANCES=$($WTL_SCRIPTS/list-instances.sh | grep -v docker inspect -f '{{index .Config.Labels "WTL_INSTANCE_NAME"}}' wikitolearn-haproxy | awk -F'-' '{ print $2 }')
else
    INSTANCES=$($WTL_SCRIPTS/list-instances.sh)
fi

for instance in $INSTANCES
do
    if [[ $(ls $WTL_RUNNING | grep ^$instance | wc -l) -eq 1 ]] ; then
        DIR_NAME=`ls $WTL_RUNNING | grep ^$instance`
        export WTL_INSTANCE_NAME="wtl-"${DIR_NAME:0:8}
        export WTL_WORKING_DIR=$WTL_RUNNING"/"$DIR_NAME
        echo $WTL_INSTANCE_NAME
        $WTL_SCRIPTS/stop.sh
        $WTL_SCRIPTS/delete.sh
        $WTL_SCRIPTS/delete-volumes.sh
        if [[ -d $WTL_WORKING_DIR ]] ; then
            rm -Rf $WTL_WORKING_DIR
        fi
    fi
done
