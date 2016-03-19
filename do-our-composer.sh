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

echo "do-our-composer $WORKDIR"

if [[ ! -d $WORKDIR ]] ; then
    echo "do-our-composer Directory '$WORKDIR' don't exist"
    exit 1
fi

. ./load-wikitolearn.sh

if [[ $WTL_COMPOSER_FOLDERS == "" ]]  ; then
    echo "do-our-composer Composing mediawiki/"
    . ./do-one-composer.sh $WORKDIR/mediawiki/
    echo "do-our-composer Composing extensions/"
    find $WORKDIR/extensions/ -maxdepth 2 -name "composer.json"  -exec dirname {} \; | while read path ; do
        echo "sono qui"
        . ./do-one-composer.sh $path
    done
else
    for folder in $WTL_COMPOSER_FOLDERS ; do
        if [[ ! -f "$folder/composer.json" ]] ; then
            echo "composer.json not found in $folder"
            exit 1
        else
            echo "trovato!"
            . ./do-one-composer.sh $path
        fi
    done
fi

