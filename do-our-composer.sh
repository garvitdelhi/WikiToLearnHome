#!/bin/bash
# Install the composer stuff required by wikitolearn 

cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "do-our-composer\tError changing directory"
 exit 1
fi

if [[ "$1" == "" ]] ; then
 echo "do-our-composer\tYou can't run this script without arguments"
 exit 1
fi

WORKDIR=$1

echo "do-our-composer\t$1"

if [[ ! -d $WORKDIR ]] ; then
 echo "do-our-composer\tDirectory '$WORKDIR' don't exist"
 exit 1
fi

. ./load-wikitolearn.sh

echo "do-our-composer\tComposing mediawiki/"
./do-one-composer.sh $WORKDIR/mediawiki/

echo "do-our-composer\tComposing extensions/"
find $WORKDIR/extensions/ -maxdepth 2 -name "composer.json"  -exec dirname {} \; | while read path ; do
  ./do-one-composer.sh $path
done
