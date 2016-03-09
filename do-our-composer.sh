#!/bin/bash
# Install the composer stuff required by wikitolearn 

cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

./do-one-composer.sh $WTL_REPO_DIR/mediawiki/

find $WTL_REPO_DIR/extensions -maxdepth 2 -name "composer.json"  -exec dirname {} \; | while read path ; do
    ./do-one-composer.sh $path
    echo $path
done