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
            if docker inspect --format '{{ .ID }}' $img &> /dev/null ; then
                wtl-event PULL_IMAGE_SKIP $img
                continue
            fi
        fi
    fi

    PULLED=0
    echo $img | if grep ^wikitolearn &> /dev/null
    then
        wtl-event PULL_IMAGE_DO registry.wikitolearn.org/$img
        if docker pull registry.wikitolearn.org/$img ; then
          docker tag registry.wikitolearn.org/$img $img
          docker rmi registry.wikitolearn.org/$img
          PULLED=1
        else
          wtl-event PULL_IMAGE_FAILED registry.wikitolearn.org/$img
        fi
    fi

    if [[ $PULLED -eq 0 ]]
    then
        wtl-event PULL_IMAGE_DO $img
        if ! docker pull $img ; then
            wtl-event PULL_IMAGE_FAILED $img
        fi
    fi

    wtl-event PULL_IMAGE_INSPECT $img
    if ! docker inspect $img &> /dev/null ; then
        wtl-event PULL_IMAGE_FAILED $img
        exit 1
    fi

    wtl-event PULL_IMAGE_FINE $img
done
