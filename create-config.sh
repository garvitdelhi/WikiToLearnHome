#!/bin/bash

#check the user that runs the script
if [[ $(id -u) -eq 0 ]] || [[ $(id -g) -eq 0 ]] ; then
 echo "You can't be root. root has too much power."
 exit 1
fi

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

#Digest arguments passed to the bash scripts
while [[ $# > 1 ]] ; do
    case $1 in
        -p | --protocol)
            protocol=$2
            shift
        ;;
        --pull-repo)
            pull_repo="yes"
        ;;
        *)
            echo "Unknown option: $1"
            exit 1
        ;;
    esac
    shift
done

#protocol handling
until [[ ${protocol,,} = "ssh" ]] || [[ ${protocol,,} = "https" ]] ; do
        echo -n "You want to use ssh or https to clone the repository? (https or ssh): "
        read protocol
done

protocol=${protocol,,}
echo "You are using $protocol"

case "$protocol" in
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

#WTL folder handling
if [[ -d "$WTL_REPO_DIR" && pull_repo != "yes" ]] ; then
	echo "$WTL_REPO_DIR directory already exists."
	echo "Delete it or move it in another folder and run again this script if you want to clone  $WTL_REPO_DIR " 
	echo "If you want to pull $WTL_REPO_DIR, please run $0 with --pull-repo argument"
	exit 1
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
