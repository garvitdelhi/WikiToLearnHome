#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "make-readonly.sh" ]] ; then
    echo "Wrong way to execute make-readonly.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh
$WTL_SCRIPTS/helpers/make-readonly/${WTL_HELPER_MAKE_READONLY}.sh "$@"
