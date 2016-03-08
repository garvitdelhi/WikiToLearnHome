#!/bin/bash
#cd to current script folder
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

#checks wether git docker curl and rsync are installed
for cmd in git docker curl rsync ; do
 echo -n "Searching for "$cmd"..."
 which $cmd &> /dev/null ; if [[ $? -ne 0 ]] ; then echo "FAIL" ; exit 1 ; else echo "OK" ; fi
done

#call ./const.sh script
. ./const.sh

#checks config file existance
if [[ -f "$WTL_CONFIG_FILE" ]] ; then
 echo "You have the '"$WTL_CONFIG_FILE"' file on your directory"
 exit 1
fi

#setting git interaction protocol
#managing script options
while [[ $# > 1 ]] ; do
  case $1 in
    -c|--commit)
      export REFERENCE="$2"
      shift
    ;;
    -t|--tag)
      export REFERENCE="$2"
      shift
    ;;
    *)
      echo "Unknow option $1"
      exit 1
    ;;
  esac
  shift
done


#allow user to select the git interaction protocol
echo -n "You want to use ssh or https to clone the repository? (https or ssh) "
read proto
proto=${proto,,}
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
  echo "You must chose between ssh or https"
  exit 1
 ;;
esac


if [[ -d "$WTL_REPO_DIR" ]] ; then
 echo "You have '"$WTL_REPO_DIR"' directory in your directory."
 echo "If you are trying to re-create the config file move the directory way and re-execute this script"
 exit 1
fi

if [[ "$WTL_INSTANCE_NAME" == "" ]] ; then
 echo "Using default instance name"
 export WTL_INSTANCE_NAME="WTL-dev"
fi

{
cat << EOF
export WTL_INSTANCE_NAME="$WTL_INSTANCE_NAME"

export WTL_URL='$WTL_URL'
export WTL_BRANCH='master'
export WTL_DOMAIN_NAME='tuttorotto.biz'
export WTL_GITHUB_TOKEN='$WTL_GITHUB_TOKEN'

# set the default plugin to use
export WTL_USE_DEFAULT="docker"
EOF
} >> $WTL_CONFIG_FILE
