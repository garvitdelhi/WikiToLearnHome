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

wtl-log scripts/download-all.sh 3 DOWNLOAD_ALL_PRE "Composer STUFF"
if [[ $WTL_PRODUCTION == "0" ]] ; then
    wtl-log scripts/download-all.sh 3 DOWNLOAD_ALL_STEP_1 "Auto compser step 1"
    if [[ $WTL_AUTO_COMPOSER == "1" ]] ; then
        wtl-log scripts/download-all.sh 3 DOWNLOAD_ALL_STEP_2 "Auto compser step 2"
        $WTL_SCRIPTS/composer-for-dirs.sh ${WTL_REPO_DIR}
    fi
fi
