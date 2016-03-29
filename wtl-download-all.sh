#!/bin/bash

cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh

. $WTL_DIR/download-code.sh

. $WTL_DIR/pull-images.sh

if [[ $WTL_PRODUCTION == "0" ]] ; then
    if [[ $WTL_AUTO_COMPOSER == "1" ]] ; then
        $WTL_DIR/do-our-composer.sh ${WTL_REPO_DIR}
    fi
fi

