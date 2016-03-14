#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

if [[ -d "$WTL_REPO_DIR" ]] ; then
 cd "$WTL_REPO_DIR"
 if [[ "$WTL_BRANCH_AUTO_CHECKOUT" == "1" ]] ; then
  git checkout "$WTL_BRANCH"
  if [[ $? -ne 0 ]] ; then
   echo "Error during checkout"
   exit 1
  fi
 fi
 git pull
 git submodule update --init --checkout --recursive --depth 10
 cd ..
else
 git clone --recursive -b "$WTL_BRANCH" "$WTL_URL" "$WTL_REPO_DIR"
fi

if [[ $WTL_PRODUCTION == "0" ]] ; then
    if [[ $WTL_AUTO_COMPOSER == "1" ]] ; then
        $WTL_DIR/do-our-composer.sh ${WTL_REPO_DIR}
    fi
fi

. $WTL_DIR/make-self-signed-certs.sh
