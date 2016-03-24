#!/bin/bash
# Install the composer stuff required by wikitolearn 

cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "do-our-composer Error changing directory"
 exit 1
fi

if [[ "$1" == "" ]] ; then
 echo "do-our-composer You can't run this script without arguments"
 exit 1
fi

WORKDIR=$1

echo "do-our-composer Working directory: $WORKDIR"

if [[ ! -d $WORKDIR ]] ; then
    echo "do-our-composer Directory '$WORKDIR' don't exist"
    exit 1
fi

if [[ ! -f $WORKDIR"/composer-dirs.conf" ]] ; then
    echo "do-our-composer File '"$WORKDIR"/composer-dirs.conf'  don't exist"
    exit 1
fi

. ./load-wikitolearn.sh

cat $WORKDIR"/composer-dirs.conf" | while read path ; do
    echo "do-our-composer: Executing do-one-composer : "$path
    . ./do-one-composer.sh $WORKDIR"/"$path
done
