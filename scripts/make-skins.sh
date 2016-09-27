#!/bin/bash
# Install the composer stuff required by wikitolearn
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "make-skins.sh" ]] ; then
    echo "Wrong way to execute composer-for-dirs.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

if [[ "$1" == "" ]] ; then
    wtl-event MAKE_SKINS_MISSING_ARGS
    exit 1
fi

WORKDIR=$1

wtl-event MAKE_SKINS_STARTING $WORKDIR

if [[ ! -d $WORKDIR ]] ; then
    wtl-event MAKE_SKINS_MISSING_WORKDIR_DIRECTORY $WORKDIR
    exit 1
fi

find $WORKDIR"/skins/" -name makeSkin.sh | while read path ; do
    $path
done
