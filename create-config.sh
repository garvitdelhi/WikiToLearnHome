#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

for cmd in git docker curl ; do
 echo -n "Searching for "$cmd"..."
 which $cmd &> /dev/null ; if [[ $? -ne 0 ]] ; then echo "FAIL" ; exit 1 ; else echo "OK" ; fi
done

. ./const.sh

if [[ -f "$W2L_CONFIG_FILE" ]] ; then
 echo "You have the '"$W2L_CONFIG_FILE"' file on your directory"
 exit 1
fi

echo -n "You want to use ssh or https to clone the repository? (https or ssh) "
read proto
case "$proto" in
 "https")
  echo "Using HTTPS"
  W2L_URL="https://github.com/WikiToLearn/WikiToLearn.git"
 ;;
 "ssh")
  echo "Using SSH"
  W2L_URL="git@github.com:WikiToLearn/WikiToLearn.git"
 ;;
 *)
  echo "You must type ssh or https lowercase"
  exit 1
 ;;
esac

if [[ -d "$W2L_REPO_DIR" ]] ; then
 echo "You have '"$W2L_REPO_DIR"' directory in your directory."
 echo "If you are trying to re-create the config file move the directory way and re-execute this script"
 exit 1
fi

if [[ "$W2L_INSTANCE_NAME" == "" ]] ; then
 echo "Using default instance name"
 export W2L_INSTANCE_NAME="w2l-dev"
fi

{
cat << EOF
export W2L_INSTANCE_NAME="$W2L_INSTANCE_NAME"

export W2L_URL='$W2L_URL'
export W2L_BRANCH='master'
export W2L_DOMAIN_NAME='tuttorotto.biz'
export W2L_GITHUB_TOKEN='$W2L_GITHUB_TOKEN'

# set the default plugin to use
export W2L_USE_DEFAULT="docker"
EOF
} >> $W2L_CONFIG_FILE
