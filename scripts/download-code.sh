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
        git checkout "$WTL_BRANCH"
        if [[ $? -ne 0 ]] ; then
            echo "[download-code] Error during checkout"
            exit 1
        fi
     fi

    echo "[download-code] pulling repo"
    git pull
    echo "[download-code] updating submodules"
    git submodule update --init --checkout --recursive
    #TODO add depth support

    cd ..
else
    echo "[download-code] cloning recursive"
    git clone --recursive -b "$WTL_BRANCH" "$WTL_URL" "$WTL_REPO_DIR"
fi
