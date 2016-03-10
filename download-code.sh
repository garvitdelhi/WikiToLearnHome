#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

if [[ -d "$WTL_REPO_DIR" ]] ; then
 cd "$WTL_REPO_DIR"
 git checkout "$WTL_BRANCH"
 git pull
 git submodule update --init --checkout --recursive
else
 git clone --recursive -b "$WTL_BRANCH" "$WTL_URL" "$WTL_REPO_DIR"
fi

if [[ $WTL_PRODUCTION == "0" ]] ; then
    $WTL_DIR/do-our-composer.sh ${WTL_REPO_DIR}
fi