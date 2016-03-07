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

if [[ $# -lt 2 ]] ; then
 echo "Missing arguments"
 echo "You have to run $0 -t <tag> or $0 -c <commit>"
 exit 1
fi

while [[ $# > 1 ]] ; do
  case $1 in
    -c|--commit)
      export COMMIT="$2"
      shift
    ;;
    -t|--tag)
      export COMMIT=`git log --pretty=format:%H "$2" | head -1`
      shift
    ;;
    *)
      echo "Unknow option $1"
      exit 1
    ;;
  esac
  shift
done

echo "Searching for commit: "$COMMIT

if [[ $(git log --pretty=format:%H "$COMMIT" | grep "$COMMIT" | wc -l) -ne 1 ]] ; then
 echo "The "$COMMIT" is not an uniq id for a commit"
 exit 1
fi
export COMMIT=$(git log --pretty=format:%H "$COMMIT" | grep "$COMMIT")

echo "Found commit: "$COMMIT

rm -f $WTL_DIR"/archives/"$COMMIT".tar"
rm -f $WTL_DIR"/archives/"$COMMIT".submodule."*
echo "Creating the archive for main repo ("$COMMIT")"
git checkout $COMMIT
git pull
git submodule update --init --checkout --recursive
git archive --format=tar -o $WTL_DIR"/archives/"$COMMIT".tar" $COMMIT
for submodule in $(git submodule foreach --recursive  | awk -F" " '{ print $2 }') ; do
 SUBMODULE_PATH=${submodule:1:-1}"/"
 C_W_D=$(pwd)
 cd $SUBMODULE_PATH
 SUBMODULE_ID=$(git log -1 --format=%H)
 echo "Creating the archive for "$SUBMODULE_PATH" repo ("$SUBMODULE_ID")"
 git archive  --prefix="$SUBMODULE_PATH" --format=tar -o $WTL_DIR"/archives/"$COMMIT".submodule."$SUBMODULE_ID".tar" $SUBMODULE_ID
 cd $C_W_D
 tar -Af $WTL_DIR"/archives/"$COMMIT.tar $WTL_DIR"/archives/"$COMMIT".submodule."$SUBMODULE_ID".tar"
done
rm -f $WTL_DIR"/archives/"$COMMIT".submodule."*
