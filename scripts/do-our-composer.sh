#!/bin/bash
# Install the composer stuff required by wikitolearn 
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "do-our-composer.sh" ]] ; then
    echo "Wrong way to execute do-our-composer.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

if [[ "$1" == "" ]] ; then
 echo "[do-our-composer] Error: Argument 'where to do our composer' required"
 exit 1
fi

WORKDIR=$1

echo "[do-our-composer] Composing 'composer-dirs.conf' in '$WORKDIR'"

if [[ ! -d $WORKDIR ]] ; then
    echo "[do-our-composer] Error: Directory '$WORKDIR' doesn't exist"
    exit 1
fi

if [[ ! -f $WORKDIR"/composer-dirs.conf" ]] ; then
    echo "[do-our-composer] Error: File '$WORKDIR/composer-dirs.conf' doesn't exist"
    exit 1
fi

. ./load-wikitolearn.sh

cat $WORKDIR"/composer-dirs.conf" | while read path ; do
    echo "[do-our-composer] Executing do-one-composer : '$path'"
    $WTL_SCRIPTS/do-one-composer.sh $WORKDIR"/"$path
done
