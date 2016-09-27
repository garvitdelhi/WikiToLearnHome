#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "create-running.sh" ]] ; then
    echo "Wrong way to execute create-running.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

if [[ -d "$WTL_REPO_DIR" ]] ; then
    cd "$WTL_REPO_DIR"
else
    wtl-event REPO_MISSING $WTL_REPO_DIR
    exit 1
fi

git update-index -q --refresh
if [[ $(git diff-index --name-only HEAD -- | wc -l) -gt 0 ]] ; then
    wtl-event REPO_DIRTY
    exit 1
fi
if [[ $(git status --porcelain | wc -l) -gt 0 ]] ; then
    wtl-event REPO_DIRTY
    exit 1
fi

if [[ $# -eq 1 ]] ; then
    WTL_REFERENCE="$1"
fi

if [[ "$WTL_REFERENCE" == "" ]] ; then
    wtl-event CREATE_RUN_MISSING_VERSION_REFERENCE
    exit 1
fi

wtl-event CREATE_RUN_SEARCH_VERSION ${WTL_REFERENCE}


if ! git show ${WTL_REFERENCE} &> /dev/null ; then
    wtl-event CREATE_RUN_MISSING_VERSION ${WTL_REFERENCE}
    exit 1
fi

wtl-event CREATE_RUN_FOUND_VERSION

git show ${WTL_REFERENCE} | cat

export WTL_WORKING_DIR=${WTL_RUNNING}"/"${WTL_REFERENCE}

if [[ -d $WTL_WORKING_DIR ]] ; then
    wtl-event CREATE_RUN_EXIST $WTL_WORKING_DIR
else
    rsync -a --stats --delete ${WTL_REPO_DIR}"/" $WTL_WORKING_DIR
    if ! cd $WTL_WORKING_DIR ; then
        wtl-event CREATE_RUN_ERROR_CREATE_COPY
        exit 1
    else
        wtl-event CREATE_RUN_COPY_CREATED $(pwd)

        git fetch
        git checkout ${WTL_REFERENCE}
        git submodule update --init --checkout --recursive

        rm -Rf .git
        find -name .git -delete

        cd ${WTL_RUNNING}
        $WTL_SCRIPTS/download-mediawiki-extensions.sh
        $WTL_SCRIPTS/composer-for-dirs.sh $WTL_WORKING_DIR
        $WTL_SCRIPTS/make-skins.sh $WTL_WORKING_DIR
    fi
fi
