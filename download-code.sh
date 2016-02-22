#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

if [[ -d "$W2L_REPO_DIR" ]] ; then
 cd "$W2L_REPO_DIR"
 git checkout "$W2L_BRANCH"
 git pull
 git submodule update --init --checkout --recursive
else
 git clone --recursive -b "$W2L_BRANCH" "$W2L_URL" "$W2L_REPO_DIR"
fi
