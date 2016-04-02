#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "download-all.sh" ]] ; then
    echo "Wrong way to execute download-all.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

$WTL_SCRIPTS/download-code.sh

$WTL_SCRIPTS/pull-images.sh

if [[ $WTL_PRODUCTION == "0" ]] ; then
    if [[ $WTL_AUTO_COMPOSER == "1" ]] ; then
        $WTL_SCRIPTS/do-our-composer.sh ${WTL_REPO_DIR}
    fi
fi

