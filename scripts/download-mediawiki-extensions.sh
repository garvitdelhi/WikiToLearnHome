#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "download-mediawiki-extensions.sh" ]] ; then
    echo "Wrong way to execute download-mediawiki-extensions.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh

test -d $WTL_CACHE"/download/" || mkdir $WTL_CACHE"/download/"
cd    $WTL_CACHE"/download/"

if [[ -f $WTL_WORKING_DIR"/mediawiki.version" ]] ; then
    export MW_MAJOR=`cat $WTL_WORKING_DIR"/mediawiki.version" | head -1`
    export MW_MINOR=`cat $WTL_WORKING_DIR"/mediawiki.version" | head -2 | tail -1`



    if [[ "$MW_MAJOR" == "snapshot" ]] ; then
        export _MW_FILE="mediawiki-snapshot-"$MW_MINOR".tar.gz"
        test -f $_MW_FILE || wget -N https://tools.wmflabs.org/snapshots/builds/mediawiki-core/$_MW_FILE

        cd $WTL_WORKING_DIR

        if [[ -d mediawiki ]] ; then
            rm -Rf mediawiki
        fi
        mkdir mediawiki
        cd mediawiki
        echo "Mediawiki snapshot:"$MW_MINOR
        tar xfz $WTL_CACHE"/download/"$_MW_FILE

    else
        export _MW_PATH=$MW_MAJOR"/"
        export _MW_DIR_NAME="mediawiki-"$MW_MAJOR"."$MW_MINOR
        export _MW_FILE=$_MW_DIR_NAME".tar.gz"
        test -f $_MW_FILE || wget -N https://releases.wikimedia.org/mediawiki/$_MW_PATH/$_MW_FILE

        cd $WTL_WORKING_DIR

        if [[ -d mediawiki ]] ; then
            rm -Rf mediawiki
        fi
        echo "Mediawiki: "$MW_MAJOR"."$MW_MINOR
        tar xfz $WTL_CACHE"/download/"$_MW_FILE
        mv $_MW_DIR_NAME mediawiki
    fi
fi

if [[ -f $WTL_WORKING_DIR"/extensions.list.version" ]] ; then
    test -d $WTL_CACHE"/download/" || mkdir $WTL_CACHE"/download/"
    test -d $WTL_CACHE"/download/extensions/" || mkdir $WTL_CACHE"/download/extensions/"
    test -d $WTL_WORKING_DIR"/extensions/" || mkdir $WTL_WORKING_DIR"/extensions/"

    cat $WTL_WORKING_DIR"/extensions.list.version" | while read dep
    do
        extension=`echo $dep | awk -F"|" '{ print $1 }'`
        extension_version=`echo $dep | awk -F"|" '{ print $2 }'`
        extension_filename=$extension"-"$extension_version".tar.gz"
        URL="https://extdist.wmflabs.org/dist/extensions/"$extension_filename
        cd $WTL_CACHE"/download/extensions/"
        test -f $extension_filename || wget -N $URL

        cd $WTL_WORKING_DIR"/extensions/"
        echo "Extension: "$extension" ("$extension_version")"
        if test -d $extension ; then
            rm -Rf $extension
        fi
        tar xfz $WTL_CACHE"/download/extensions/"$extension_filename
    done
fi
