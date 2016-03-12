#!/bin/bash
cd $(dirname $(realpath $0))

REFERENCE="$1"

if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

if [[ -d "$WTL_REPO_DIR" ]] ; then
 cd "$WTL_REPO_DIR"
else
 echo "Missing the '$WTL_REPO_DIR' directory"
 exit 1
fi

git update-index -q --refresh
if [[ $(git diff-index --name-only HEAD -- | wc -l) -gt 0 ]] ; then
 echo "You have to commit/rollback all changes before this"
 exit 1
fi
if [[ $(git status --porcelain | wc -l) -gt 0 ]] ; then
 echo "You have to commit/rollback all changes before this"
 exit 1
fi

if [[ $# -ne 1 ]] ; then
 echo "Missing arguments"
 echo "You have to run $0 <commit|tag>"
 exit 1
fi

if [[ "$REFERENCE" == "" ]] ; then
 echo "Missing the reference to commit or tag"
 exit 1
fi

echo "Searching for commit for "${REFERENCE}

git show ${REFERENCE} &> /dev/null
if [[ $? -ne 0 ]] ; then
 echo "The "${REFERENCE}" is not an uniq id for a commit"
 exit 1
fi

echo "Found!"

git show ${REFERENCE}

if [[ -d ${WTL_RUNNING}"/"${REFERENCE} ]] ; then
 echo "Directory "${WTL_RUNNING}"/"${REFERENCE}" exist"
else
 rsync -a --stats --delete ${WTL_REPO_DIR}"/" ${WTL_RUNNING}"/"${REFERENCE}
 cd ${WTL_RUNNING}"/"${REFERENCE}
 if [[ $? -ne 0 ]] ; then
  echo "Error in the change directory operation"
  exit 1
 else
  echo "New location"

  git checkout ${REFERENCE}
  git submodule update --init --checkout --recursive

  rm -Rf .git
  find -name .git -delete

  cd ${WTL_RUNNING}
  echo "DO COMPOSER"
  $WTL_DIR/do-our-composer.sh ${WTL_RUNNING}"/"${REFERENCE}
 fi
fi
