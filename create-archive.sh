#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

if [[ -d "$W2L_REPO_DIR" ]] ; then
 cd "$W2L_REPO_DIR"
else
 echo "Missing the '$W2L_REPO_DIR' directory"
 exit 1
fi

while [[ $# > 1 ]] ; do
  case $1 in
    -c|--commit)
      export COMMIT="$2"
      shift
    ;;
    -t|--tag)
      export COMMIT=`git log -1 --pretty=format:%H "$2"`
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

if [[ $(git log --pretty=format:%H | grep "$COMMIT" | wc -l) -ne 1 ]] ; then
 echo "The "$COMMIT" is not an uniq id for a commit"
 exit 1
fi
export COMMIT=$(git log --pretty=format:%H | grep "$COMMIT")

echo "Found commit: "$COMMIT

rm -f $W2L_DIR"/archives/"$COMMIT".tar"
rm -f $W2L_DIR"/archives/"$COMMIT".submodule."*
echo "Creating the archive for main repo ("$COMMIT")"
git archive --format=tar -o $W2L_DIR"/archives/"$COMMIT".tar" $COMMIT
for submodule in $(git submodule | awk '{ print $1"@"$2 }') ; do
 SUBMODULE_ID=${submodule:0:40}
 SUBMODULE_PATH=${submodule:41}"/"
 C_W_D=$(pwd)
 cd $SUBMODULE_PATH
 echo "Creating the archive for "$SUBMODULE_PATH" repo ("$SUBMODULE_ID")"
 git archive  --prefix="$SUBMODULE_PATH" --format=tar -o $W2L_DIR"/archives/"$COMMIT".submodule."$SUBMODULE_ID".tar" $SUBMODULE_ID
 cd $C_W_D
 tar -Af $W2L_DIR"/archives/"$COMMIT.tar $W2L_DIR"/archives/"$COMMIT".submodule."$SUBMODULE_ID".tar"
done
rm -f $W2L_DIR"/archives/"$COMMIT".submodule."*
