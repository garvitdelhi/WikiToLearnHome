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

if [[ "$1" == "" ]] ; then
 echo "[composer-for-dirs] Error: Argument 'where to do our composer' required"
 exit 1
fi

WORKDIR=$1

echo "[composer-for-dirs] Composing 'composer-dirs.conf' in '$WORKDIR'"

if [[ ! -d $WORKDIR ]] ; then
    echo "[composer-for-dirs] Error: Directory '$WORKDIR' doesn't exist"
    exit 1
fi

if [[ ! -f $WORKDIR"/composer-dirs.conf" ]] ; then
    echo "[composer-for-dirs] Error: File '$WORKDIR/composer-dirs.conf' doesn't exist"
    exit 1
fi

. ./load-libs.sh

cat $WORKDIR"/composer-dirs.conf" | while read path ; do
    echo "[composer-for-dirs] Executing composer-dir : '$path'"
    $WTL_SCRIPTS/composer-dir.sh $WORKDIR"/"$path
done
