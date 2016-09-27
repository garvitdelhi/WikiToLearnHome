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

if [[ $WTL_PRODUCTION == "0" ]] || [[ $WTL_AUTO_COMPOSER == "1" ]] ; then
    wtl-event DOWNLOAD_ALL_COMPOSER_FOR_DIRS ${WTL_REPO_DIR}
    $WTL_SCRIPTS/composer-for-dirs.sh ${WTL_REPO_DIR}
    $WTL_SCRIPTS/make-skins.sh ${WTL_REPO_DIR}
fi
