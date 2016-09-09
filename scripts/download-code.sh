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
            wtl-log scripts/download-code.sh 7 DOWNLOAD_CODE_ERROR_CHECKOUT "Error during checkout"
            exit 1
        fi
     fi

    wtl-log scripts/download-code.sh 7 DOWNLOAD_CODE_PULL "pulling repo"
    git pull
    wtl-log scripts/download-code.sh 7 DOWNLOAD_CODE_SUBMODULE_SYNC "syncing submodules"
    git submodule sync
    wtl-log scripts/download-code.sh 7 DOWNLOAD_CODE_SUBMODULE_INIT_UPDATE "updating submodules"
    git submodule update --init --checkout --recursive

    cd ..
else
    wtl-log scripts/download-code.sh 7 DOWNLOAD_CODE_CLONE "cloning recursive"
    git clone --recursive -b "$WTL_BRANCH" "$WTL_URL" "$WTL_REPO_DIR"
fi
