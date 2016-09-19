#!/bin/bash
# Install the composer stuff required by wikitolearn
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "composer-for-dirs.sh" ]] ; then
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
    wtl-event COMPOSER_MISSING_ARGS
    exit 1
fi

WORKDIR=$1

wtl-event COMPOSER_STARTING $WORKDIR

if [[ ! -d $WORKDIR ]] ; then
    wtl-event COMPOSER_MISSING_WORKDIR_DIRECTORY $WORKDIR
    exit 1
fi

if [[ ! -f $WORKDIR"/composer-dirs.conf" ]] ; then
    wtl-event COMPOSER_MISSING_COMPOSER_DIRS_CONF $WORKDIR
    exit 1
fi

. ./load-libs.sh

cat $WORKDIR"/composer-dirs.conf" | while read path ; do
    wtl-event COMPOSER_EXECUTING $path
    $WTL_SCRIPTS/composer-dir.sh $WORKDIR"/"$path
done
