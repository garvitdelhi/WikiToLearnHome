#!/bin/bash
#add the symlink going from our folder, inside mediawiki, so we avoid changes to the mediawiki folder
cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

#remove old one, to make sure
rm $WTL_REPO_DIR/mediawiki/LocalSettings.php
rm $WTL_REPO_DIR/mediawiki/skins/Neverland
rm -r $WTL_REPO_DIR/mediawiki/extensions
rm $WTL_REPO_DIR/mediawiki/favicon.ico

#add symlink
ln -s $WTL_REPO_DIR/LocalSettings.php $WTL_REPO_DIR/mediawiki/LocalSettings.php
ln -s $WTL_REPO_DIR/Neverland         $WTL_REPO_DIR/mediawiki/skins/Neverland
ln -s $WTL_REPO_DIR/extensions        $WTL_REPO_DIR/mediawiki/extensions
ln -s $WTL_REPO_DIR/favicon.ico       $WTL_REPO_DIR/mediawiki/favicon.ico