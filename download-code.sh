#!/bin/bash

cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
    echo "[download-code] Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh

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