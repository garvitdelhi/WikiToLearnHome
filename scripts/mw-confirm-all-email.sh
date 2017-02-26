#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "mw-confirm-all-email.sh" ]] ; then
    echo "Wrong way to execute mw-confirm-all-email.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
    wtl-event MIGGING_WTL_INSTANCE_NAME
    exit 1
fi
docker exec -ti $WTL_INSTANCE_NAME-mysql mysql sharedwikitolearn -e "update user set user_email_authenticated = user_registration;"

