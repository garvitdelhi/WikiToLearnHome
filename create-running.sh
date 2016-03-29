#!/bin/bash
cd $(dirname $(realpath $0))

if [[ ! -f "$0" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-wikitolearn.sh

if [[ -d "$WTL_REPO_DIR" ]] ; then
    cd "$WTL_REPO_DIR"
else
    wtl-log create-running.sh 0 REPO_MISSING "Missing the '$WTL_REPO_DIR' directory"
    exit 1
fi

git update-index -q --refresh
if [[ $(git diff-index --name-only HEAD -- | wc -l) -gt 0 ]] ; then
    wtl-log create-running.sh 0 REPO_DIRTY "Dirty repo. You have to rollback/commit before"
    exit 1
fi
if [[ $(git status --porcelain | wc -l) -gt 0 ]] ; then
    wtl-log create-running.sh 0 REPO_DIRTY "Dirty repo. You have to rollback/commit before"
    exit 1
fi

if [[ $# -eq 1 ]] ; then
    WTL_REFERENCE="$1"
fi

if [[ "$WTL_REFERENCE" == "" ]] ; then
    wtl-log create-running.sh 0 CREATE_RUN_MISSING_VERSION_REFERENCE "You have to specify the version of WikiToLearn (commit or tag)"
    exit 1
fi

wtl-log create-running.sh 3 CREATE_RUN_SEARCH_VERSION "Searching for commit for "${WTL_REFERENCE}

git show ${WTL_REFERENCE} &> /dev/null
if [[ $? -ne 0 ]] ; then
    wtl-log create-running.sh 0 CREATE_RUN_MISSING_VERSION "The "${WTL_REFERENCE}" is not an uniq id for a commit"
    exit 1
fi

wtl-log create-running.sh 3 CREATE_RUN_FOUND_VERSION "Found!"

git show ${WTL_REFERENCE}

if [[ -d ${WTL_RUNNING}"/"${WTL_REFERENCE} ]] ; then
    wtl-log create-running.sh 1 CREATE_RUN_EXIST "Directory already "${WTL_RUNNING}"/"${WTL_REFERENCE}" exist"
else
    rsync -a --stats --delete ${WTL_REPO_DIR}"/" ${WTL_RUNNING}"/"${WTL_REFERENCE}
    cd ${WTL_RUNNING}"/"${WTL_REFERENCE}
    if [[ $? -ne 0 ]] ; then
        wtl-log create-running.sh 0 CREATE_RUN_ERROR_CREATE_COPY "Error in the change directory operation"
        exit 1
    else
        wtl-log create-running.sh 1 CREATE_RUN_COPY_CREATED "New location: "$(pwd)

        git checkout ${WTL_REFERENCE}
        git submodule update --init --checkout --recursive

        rm -Rf .git
        find -name .git -delete

        cd ${WTL_RUNNING}

        wtl-log create-running.sh 1 CREATE_RUN_COPY_CREATED "Started composer"

        $WTL_DIR/do-our-composer.sh ${WTL_RUNNING}"/"${WTL_REFERENCE}
    fi
fi
