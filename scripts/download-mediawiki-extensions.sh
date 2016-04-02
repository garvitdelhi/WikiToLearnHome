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

if [[ -f $WTL_WORKING_DIR"/mediawiki.version" ]] ; then
    export MW_MAJOR=`cat $WTL_WORKING_DIR"/mediawiki.version" | head -1`
    export MW_MINOR=`cat $WTL_WORKING_DIR"/mediawiki.version" | head -2 | tail -1`

    test -d $WTL_CACHE"/download/" || mkdir $WTL_CACHE"/download/"
    cd    $WTL_CACHE"/download/"
    test -f mediawiki-$MW_MAJOR.$MW_MINOR.tar.gz || wget -N https://releases.wikimedia.org/mediawiki/$MW_MAJOR/mediawiki-$MW_MAJOR.$MW_MINOR.tar.gz

    cd $WTL_WORKING_DIR

    if [[ -d mediawiki ]] ; then
        rm -Rf mediawiki
    fi
    echo "Mediawiki: "$MW_MAJOR"."$MW_MINOR
    tar xfz $WTL_CACHE"/download/mediawiki-"$MW_MAJOR"."$MW_MINOR".tar.gz"
    mv mediawiki{-$MW_MAJOR.$MW_MINOR,}
fi

if [[ -f $WTL_WORKING_DIR"/extensions.list.version" ]] ; then
    cat $WTL_WORKING_DIR"/extensions.list.version" | while read dep
    do
        extension=`echo $dep | awk -F"|" '{ print $1 }'`
        extension_version=`echo $dep | awk -F"|" '{ print $2 }'`
        URL="https://extdist.wmflabs.org/dist/extensions/"$extension"-"$extension_version".tar.gz"
        test -d $WTL_CACHE"/download/" || mkdir $WTL_CACHE"/download/"
        test -d $WTL_CACHE"/download/extensions/" || mkdir $WTL_CACHE"/download/extensions/"
        cd $WTL_CACHE"/download/extensions/"
        test -f $extension"-"$extension_version".tar.gz" || wget -N $URL
    done

    test -d $WTL_WORKING_DIR"/extensions/" || mkdir $WTL_WORKING_DIR"/extensions/"
    cd $WTL_WORKING_DIR"/extensions/"
    cat $WTL_WORKING_DIR"/extensions.list.version"  | while read dep
    do
        extension=`echo $dep | awk -F"|" '{ print $1 }'`
        extension_version=`echo $dep | awk -F"|" '{ print $2 }'`
        echo "Extension: "$extension" ("$extension_version")"
        if test -d $extension ; then
            rm -Rf $extension
        fi
        tar xfz $WTL_CACHE"/download/extensions/"$extension"-"$extension_version".tar.gz"
    done
fi
