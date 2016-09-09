#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "docker-images-delete-old-images.sh" ]] ; then
    echo "Wrong way to execute docker-images-delete-old-images.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh

for img  in $(docker images --filter "dangling=false" -q) ; do
    i=0
    STATUS=0
    while [[ $STATUS -eq 0 ]] ; do
        {
            IMG_TAG=$(docker inspect -f '{{index .RepoTags '$i'}}' $img) || STATUS=$?
        } &> /dev/null
        i=$(($i+1))
        if [[ $STATUS -eq 0 ]] ; then
            wtl-log docker-images-delete-old-images.sh 7 DOCKER_IMAGES_DELETE_OLD_IMAGES_NAME "=> "$IMG_TAG
            FOUND=0
            for img_env_name in $WTL_DOCKER_IMAGES_LIST; do
                img=$(echo 'echo $'$img_env_name | bash)
                if [[ "$IMG_TAG" == "$img" ]] ; then
                    FOUND=1
                fi
            done
            if [[ $FOUND -eq 0 ]] ; then
                docker rmi $IMG_TAG
            fi
        fi
    done
done
