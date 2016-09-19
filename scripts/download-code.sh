#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "download-code.sh" ]] ; then
    echo "Wrong way to execute download-code.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

if [[ -d "$WTL_REPO_DIR" ]] ; then
    cd "$WTL_REPO_DIR"

    if [[ "$WTL_BRANCH_AUTO_CHECKOUT" == "1" ]] ; then
        if ! git checkout "$WTL_BRANCH" ; then
            wtl-event DOWNLOAD_CODE_ERROR_CHECKOUT
            exit 1
        fi
     fi

    wtl-event DOWNLOAD_CODE_PULL
    git pull
    wtl-event DOWNLOAD_CODE_SUBMODULE_SYNC
    git submodule sync
    wtl-event DOWNLOAD_CODE_SUBMODULE_INIT_UPDATE
    git submodule update --init --checkout --recursive

    cd ..
else
    wtl-event DOWNLOAD_CODE_CLONE
    git clone --recursive -b "$WTL_BRANCH" "$WTL_URL" "$WTL_REPO_DIR"
fi
