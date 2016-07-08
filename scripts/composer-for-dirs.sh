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
    wtl-log scripts/composer-for-dirs.sh 0 COMPOSER_MISSING_ARGS "Argument 'where to do our composer' required"
    exit 1
fi

WORKDIR=$1

wtl-log scripts/composer-for-dirs.sh 3 COMPOSER_STARTING "Composing 'composer-dirs.conf' in '$WORKDIR'"

if [[ ! -d $WORKDIR ]] ; then
    wtl-log scripts/composer-for-dirs.sh 0 COMPOSER_MISSING_WORKDIR_DIRECTORY "Directory '$WORKDIR' doesn't exist"
    exit 1
fi

if [[ ! -f $WORKDIR"/composer-dirs.conf" ]] ; then
    wtl-log scripts/composer-for-dirs.sh 0 COMPOSER_MISSING_COMPOSER_DIRS_CONF "File '$WORKDIR/composer-dirs.conf' doesn't exist"
    exit 1
fi

. ./load-libs.sh

cat $WORKDIR"/composer-dirs.conf" | while read path ; do
    wtl-log scripts/composer-for-dirs.sh 3 COMPOSER_EXECUTING "Executing composer-dir : '$path'"
    $WTL_SCRIPTS/composer-dir.sh $WORKDIR"/"$path
done
