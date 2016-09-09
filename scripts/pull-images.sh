#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "pull-images.sh" ]] ; then
    echo "Wrong way to execute pull-images.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh
. $WTL_SCRIPTS/environments/$WTL_ENV.sh

for img_env_name in $WTL_DOCKER_IMAGES_LIST; do
    img=$(echo 'echo $'$img_env_name | bash)

    if [[ "$WTL_FORCE_DOCKER_PULL" != "1" ]] ; then
        if [[ "$WTL_PRODUCTION" != "1" ]] ; then
            wtl-log scripts/pull-images.sh 7 PULL_IMAGE_SKIP "The image "$img" is on your system, you can run 'docker pull "$img"' to force the update"
            continue
        fi
    fi

    wtl-log scripts/pull-images.sh 7 PULL_IMAGE_DO " Pulling '$img'"
    if ! docker pull $img ; then
        wtl-log scripts/pull-images.sh 7 PULL_IMAGE_FAILED " Failed pull for '$img'"
    fi

    wtl-log scripts/pull-images.sh 7 PULL_IMAGE_INSPECT " '$img' pulled, inspecting"
    if ! docker inspect $img &> /dev/null ; then
        wtl-log scripts/pull-images.sh 7 PULL_IMAGE_FAILED "Error downloading '$img' image. Check Internet connection and then restart the script"
        exit 1
    fi

    wtl-log scripts/pull-images.sh 7 PULL_IMAGE_FINE "'$img' pulled and it's fine!"
done
