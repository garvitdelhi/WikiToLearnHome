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
    echo "configuration aborted"
    exit 1
fi

#checks whether git docker curl and rsync are installed
for cmd in git docker curl rsync ; do
    echo -n "Searching for "$cmd"..."
    which $cmd &> /dev/null ; if [[ $? -ne 0 ]] ; then echo "FAIL" ; exit 1 ; else echo "OK" ; fi
done

#call ./const.sh script: load constant environment variables
. ./const.sh

#checks config file existance
if [[ -f "$WTL_CONFIG_FILE" ]] ; then
    echo "You have the '"$WTL_CONFIG_FILE"' file on your directory"
    echo "configuration aborted"
    exit 1
fi

#Digest arguments passed to the bash scripts
while [[ $# > 0 ]] ; do
    case $1 in
        -p | --protocol)
            if [[ $protocol != "" ]] ; then
                echo "$protocol has been overwritten by $2"
            fi
            protocol=$2
            shift
        ;;
        --existing-repo)
            existing_repo="yes"
        ;;
        -e | --environment)
            WTL_ENV=$2
            shift
        ;;
        -t | --token)
            WTL_GITHUB_TOKEN=$2
            shift
        ;;
        *)
            echo "Unknown option: $1"
            echo "configuration aborted"
            exit 1
        ;;
    esac
    shift
done

#protocol handling
until [[ ${protocol,,} == "ssh" ]] || [[ ${protocol,,} == "https" ]] ; do
    echo -n "You want to use ssh or https to clone the repository? (https or ssh): "
    read protocol
done

protocol=${protocol,,}
echo "You are using $protocol"

#control if http or ssh
if [[ $protocol == "https" ]] ; then
    WTL_URL="https://github.com/WikiToLearn/WikiToLearn.git"
elif [[ $protocol == "ssh" ]] ; then
    WTL_URL="git@github.com:WikiToLearn/WikiToLearn.git"
fi

#WTL folder handling
if [[ -d "$WTL_REPO_DIR" ]] && [[ $existing_repo != "yes" ]] ; then
    echo "$WTL_REPO_DIR directory already exists."
    echo "Delete it or move it in another folder and run again this script if you want to clone  $WTL_REPO_DIR " 
    echo "If you want to pull $WTL_REPO_DIR, please run $0 with --existing-repo argument"
    echo "configuration aborted"
    exit 1
fi

#GitHub token handling
if [[ "$WTL_GITHUB_TOKEN" == "" ]] ; then
    if [[ -f "$WTL_DIR/configs/composer/auth.json" ]] ; then
        echo "I will use the already existing github token in '$WTL_DIR/configs/composer/auth.json'"
   else
        echo "You must insert '--token' parameter followed by a valid token"
        echo "visit https://git.io/vmNUX to learn how to obtain the token"
        echo "configuration aborted"
        exit 1
    fi
elif [[ ${WTL_GITHUB_TOKEN:0:1} == "-" ]] ; then
    echo "$WTL_GITHUB_TOKEN seems to be a parameter, but I need a github token after '--token'"
    echo "re-write the script with '--token' parameter followed by the token"
    echo "visit https://git.io/vmNUX to learn how to obtain the token"
    echo "configuration aborted"
    exit 1
else

#Environment
if [[ $WTL_ENV == "" ]] ; then
    WTL_ENV="develop"
fi

if [[ ! -f "$WTL_DIR/helper/$WTL_ENV.sh" ]] ; then
    echo "$WTL_ENV is not a valid environment"
    echo "re-execute the script using '-e' followed by one of those valid environments:"
    for script in $( ls $WTL_DIR/helper | grep -v - ) ; do 
        echo "$env_options ${script//.sh}"
    done
    exit 1
fi

#Store GitHub token
if [[ ! -d $WTL_DIR/configs/composer ]]; then
    mkdir $WTL_DIR/configs/composer
fi

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

#saving the user
export _WTL_USER_UID=$(id -u)
export _WTL_USER_GID=$(id -g)

#Config file creation
{
cat << EOF
export WTL_URL='$WTL_URL'
export WTL_BRANCH='master'
export WTL_DOMAIN_NAME='tuttorotto.biz'
export WTL_GITHUB_TOKEN='$WTL_GITHUB_TOKEN'

export WTL_USER_UID=$_WTL_USER_UID
export WTL_USER_GID=$_WTL_USER_GID

# set the default plugin to use
export WTL_ENV='$WTL_ENV'
EOF
} >> $WTL_CONFIG_FILE

if [[ -f "$WTL_CONFIG_FILE" ]] ; then
 echo "configuration file created"
fi
