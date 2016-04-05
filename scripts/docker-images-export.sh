#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "docker-images-export.sh" ]] ; then
    echo "Wrong way to execute docker-images-export.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

test -d $WTL_CACHE"/docker-images/" || mkdir $WTL_CACHE"/docker-images/"
docker images --format "{{.Repository}}:{{.Tag}}" --filter "dangling=false" | sort | while read img
do
    img_name=`echo $img | awk -F":" '{ print $1 }'`
    img_tag=`echo $img | awk -F":" '{ print $2 }'`
    echo "Image: "$img
    DIRNAME=$WTL_CACHE"/docker-images/"$img_name"/"
    test -d $DIRNAME || mkdir -p $DIRNAME
    FILENAME=$DIRNAME$img_tag".tar"
    if test ! -f $FILENAME ; then
        echo "Export to "$FILENAME
        docker save -o $FILENAME $img
    fi
done
