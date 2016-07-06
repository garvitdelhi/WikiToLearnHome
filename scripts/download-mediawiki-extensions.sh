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
        wtl-log download-mediawiki-extensions.sh 3 DOWNLOAD_MEDIAWIKI_EXTENSIONS_CORE_SNAPSHOT "Mediawiki snapshot:"$MW_MINOR
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
        wtl-log download-mediawiki-extensions.sh 3 DOWNLOAD_MEDIAWIKI_EXTENSIONS_CORE "Mediawiki: "$MW_MAJOR"."$MW_MINOR
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
        test -f $extension_filename || wget -N $URL || true

        if test ! -f $extension_filename ; then
                branchname=$(echo $extension_version | awk -F"-" '{ print $1 }')
                commit=$(echo $extension_version | awk -F"-" '{ print $2 }')
                commit=${commit:0:7}
                if test -d $extension ; then
                    cd $extension
                    git checkout $branchname
                    git pull
                    git submodule sync
                    git submodule update --init --checkout --recursive
                    cd ..
                else
                    git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/$extension.git -b $branchname --recursive
                fi
                cd $extension
                {
                    ext_cwd=`pwd`
                    git archive $branchname --prefix $extension/ --format=tar --output ../$extension-$branchname-$commit.tar
                    I=0
                    for e in $(git submodule | awk '{ print $2 }')
                    do
                        I=$(($I+1))
                        cd "$ext_cwd"
                        cd "$e"
                        git archive $(git log -1 --format=%H) --prefix $extension/$e/ --format=tar --output $ext_cwd/../$extension-$branchname-$commit-$I.tar
                        tar --concatenate --file=$ext_cwd/../$extension-$branchname-$commit.tar $ext_cwd/../$extension-$branchname-$commit-$I.tar
                        rm $ext_cwd/../$extension-$branchname-$commit-$I.tar
                    done
                    cd "$ext_cwd"
                    gzip ../$extension-$branchname-$commit.tar
                }
        fi

        cd $WTL_WORKING_DIR"/extensions/"
        wtl-log download-mediawiki-extensions.sh 3 DOWNLOAD_MEDIAWIKI_EXTENSIONS_EXT "Extension: "$extension" ("$extension_version")"
        if test -d $extension ; then
            rm -Rf $extension
        fi
        tar xfz $WTL_CACHE"/download/extensions/"$extension_filename
    done
fi
