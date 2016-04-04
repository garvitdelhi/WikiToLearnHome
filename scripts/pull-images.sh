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
    echo "[pull-images] Pulling '$img'"
    if ! docker pull $img ; then
        echo "[pull-images] Failed pull for '$img'"
    fi

    echo "[pull-images] '$img' pulled, inspecting"
    docker inspect $img &> /dev/null
    if [[ $? -ne 0 ]] ; then
        echo "[pull-images] Error downloading '$img' image. Check Internet connection and then restart the script"
        exit 1
    fi

    echo "[pull-images] '$img' pulled and it's fine!"
done
