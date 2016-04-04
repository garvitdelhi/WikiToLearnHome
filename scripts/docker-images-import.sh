#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "import-docker-images.sh" ]] ; then
    echo "Wrong way to execute import-docker-images.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

test -d $WTL_CACHE"/docker-images/" || mkdir $WTL_CACHE"/docker-images/"
find $WTL_CACHE"/docker-images/" -type f -exec docker load -i {} \;
