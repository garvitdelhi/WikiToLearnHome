#!/bin/bash
# Install the composer stuff required by wikitolearn 

cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

if [[ "$1" == "" ]] ; then
 echo "You can't run this script without arguments"
 exit 1
fi

WORKDIR=$1

echo $1

if [[ ! -d $WORKDIR ]] ; then
 echo "Directory "$WORKDIR" don't exist"
 exit 1
fi

. ./load-wikitolearn.sh

./do-one-composer.sh $WORKDIR/mediawiki/

find $WORKDIR/extensions -maxdepth 2 -name "composer.json"  -exec dirname {} \; | while read path ; do
    ./do-one-composer.sh $path
    echo $path
done
