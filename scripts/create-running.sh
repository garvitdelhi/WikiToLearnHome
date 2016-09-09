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
    wtl-log scripts/create-running.sh 4 REPO_MISSING "Missing the '$WTL_REPO_DIR' directory"
    exit 1
fi

git update-index -q --refresh
if [[ $(git diff-index --name-only HEAD -- | wc -l) -gt 0 ]] ; then
    wtl-log scripts/create-running.sh 4 REPO_DIRTY "Dirty repo. You have to rollback/commit before"
    exit 1
fi
if [[ $(git status --porcelain | wc -l) -gt 0 ]] ; then
    wtl-log scripts/create-running.sh 4 REPO_DIRTY "Dirty repo. You have to rollback/commit before"
    exit 1
fi

if [[ $# -eq 1 ]] ; then
    WTL_REFERENCE="$1"
fi

if [[ "$WTL_REFERENCE" == "" ]] ; then
    wtl-log scripts/create-running.sh 4 CREATE_RUN_MISSING_VERSION_REFERENCE "You have to specify the version of WikiToLearn (commit or tag)"
    exit 1
fi

wtl-log scripts/create-running.sh 7 CREATE_RUN_SEARCH_VERSION "Searching for commit for "${WTL_REFERENCE}


if ! git show ${WTL_REFERENCE} &> /dev/null ; then
    wtl-log scripts/create-running.sh 4 CREATE_RUN_MISSING_VERSION "The "${WTL_REFERENCE}" is not an uniq id for a commit"
    exit 1
fi

wtl-log scripts/create-running.sh 7 CREATE_RUN_FOUND_VERSION "Found!"

git show ${WTL_REFERENCE} | cat

export WTL_WORKING_DIR=${WTL_RUNNING}"/"${WTL_REFERENCE}

if [[ -d $WTL_WORKING_DIR ]] ; then
    wtl-log scripts/create-running.sh 5 CREATE_RUN_EXIST "Directory already "$WTL_WORKING_DIR" exist"
else
    rsync -a --stats --delete ${WTL_REPO_DIR}"/" $WTL_WORKING_DIR
    if ! cd $WTL_WORKING_DIR ; then
        wtl-log scripts/create-running.sh 4 CREATE_RUN_ERROR_CREATE_COPY "Error in the change directory operation"
        exit 1
    else
        wtl-log scripts/create-running.sh 5 CREATE_RUN_COPY_CREATED "New location: "$(pwd)

        git checkout ${WTL_REFERENCE}
        git submodule update --init --checkout --recursive

        rm -Rf .git
        find -name .git -delete

        cd ${WTL_RUNNING}

        wtl-log scripts/create-running.sh 5 CREATE_RUN_COPY_CREATED "Started composer"

        $WTL_SCRIPTS/download-mediawiki-extensions.sh
        $WTL_SCRIPTS/composer-for-dirs.sh $WTL_WORKING_DIR
    fi
fi
