#!/bin/bash

if [[ $(id -u) -eq 0 ]] || [[ $(id -g) -eq 0 ]] ; then
 echo "You can't be root. root has too much power."
 exit 1
fi

cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

for cmd in git docker curl rsync ; do
 echo -n "Searching for "$cmd"..."
 which $cmd &> /dev/null ; if [[ $? -ne 0 ]] ; then echo "FAIL" ; exit 1 ; else echo "OK" ; fi
done

. ./const.sh

if [[ -f "$WTL_CONFIG_FILE" ]] ; then
 echo "You have the '"$WTL_CONFIG_FILE"' file on your directory"
 exit 1
fi

echo -n "You want to use ssh or https to clone the repository? (https or ssh) "
read proto
case "$proto" in
 "https")
  echo "Using HTTPS"
  WTL_URL="https://github.com/WikiToLearn/WikiToLearn.git"
 ;;
 "ssh")
  echo "Using SSH"
  WTL_URL="git@github.com:WikiToLearn/WikiToLearn.git"
 ;;
 *)
  echo "You must type ssh or https lowercase"
  exit 1
 ;;
esac

#if [[ -d "$WTL_REPO_DIR" ]] ; then
# echo "You have '"$WTL_REPO_DIR"' directory in your directory."
# echo "If you are trying to re-create the config file move the directory way and re-execute this script"
# exit 1
#fi

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
 echo "Using default instance name"
 export WTL_INSTANCE_NAME="WTL-dev"
fi


echo -n "GitHub Auth Token: "
read WTL_GITHUB_TOKEN
if [[ "$WTL_GITHUB_TOKEN" == "" ]] ; then
 echo "A token is REQUIRED!"
 exit 1
else
    cat <<EOF > $WTL_DIR/configs/composer/auth.json 
{
   "config":{
      "github-oauth":{
         "github.com":"$WTL_GITHUB_TOKEN"
      }
   }
}
EOF
fi

export _WTL_USER_UID=$(id -u)
export _WTL_USER_GID=$(id -g)

{
cat << EOF
export WTL_INSTANCE_NAME="$WTL_INSTANCE_NAME"

export WTL_URL='$WTL_URL'
export WTL_BRANCH='master'
export WTL_DOMAIN_NAME='tuttorotto.biz'
export WTL_GITHUB_TOKEN='$WTL_GITHUB_TOKEN'

export WTL_USER_UID=$_WTL_USER_UID
export WTL_USER_GID=$_WTL_USER_GID

# set the default plugin to use
export WTL_USE_DEFAULT="docker"
EOF
} >> $WTL_CONFIG_FILE
