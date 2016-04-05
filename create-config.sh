#!/bin/bash


#check the user that runs the script
if [[ $(id -u) -eq 0 ]] || [[ $(id -g) -eq 0 ]] ; then
    echo "[create-config] You can't be root. root has too much power."
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
fi

#cd to current script folder
cd $(dirname $(realpath $0))
if [[ ! -f "create-config.sh" ]] ; then
    echo "[create-config] Error changing directory"
    echo "configuration aborted"
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
fi

#checks whether git docker curl and rsync are installed
for cmd in git docker curl rsync python dirname realpath ; do
    echo -n "[create-config] Searching for "$cmd"..."
    which $cmd &> /dev/null
    if [[ $? -ne 0 ]] ; then
        echo -e "\e[31mFATAL ERROR \e[0m"
        exit 1
    else
        echo "OK"
    fi
done

docker info  &> /dev/null
if [[ $? -ne 0 ]] ; then
    echo "[create-config] The command 'docker info' failed."
    echo "docker service is not running,"
    echo "or at least you don't have the permissions to use the service."
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
fi

DOCKER_CURR_VERSION=$(docker version --format '{{.Server.Version}}')
DOCKER_REQUIRED_VERSION="1.10.3"
if [  "$DOCKER_REQUIRED_VERSION" != "`echo -e "$DOCKER_REQUIRED_VERSION\n$DOCKER_CURR_VERSION" | sort -V | head -n1`" ] ; then
    echo "[create-config] Docker version failed."
    echo "This version of WikiToLearn Home requires docker "$DOCKER_REQUIRED_VERSION" and you have the "$DOCKER_CURR_VERSION
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
fi

#call ./const.sh script: load constant environment variables
. ./const.sh

# default value for variabile
export WTL_PRODUCTION=0
export WTL_ENV="base"
export WTL_DOMAIN_NAME='tuttorotto.biz'
export WTL_AUTO_COMPOSER=1
export WTL_BRANCH_AUTO_CHECKOUT=1
export WTL_BRANCH='master'

#Digest arguments passed to the bash scripts
while [[ $# > 0 ]] ; do
    case $1 in
        -p | --protocol)
            if [[ $protocol != "" ]] ; then
                echo "[create-config] $protocol has been overwritten by $2"
            fi
            export protocol=$2
            shift
        ;;
        --existing-repo)
            export existing_repo="yes"
        ;;
        -t | --token)
            export WTL_GITHUB_TOKEN=$2
            shift
        ;;
        -e | --environment)
            export WTL_ENV=$2
            shift
        ;;
        --production)
            export WTL_PRODUCTION=1
        ;;
        --domain)
            export WTL_DOMAIN_NAME=$2
            shift
        ;;
        --branch)
            export WTL_BRANCH=$2
            shift
        ;;
        --no-auto-checkout)
            export WTL_BRANCH_AUTO_CHECKOUT=0
        ;;
        --no-auto-composer)
            export WTL_AUTO_COMPOSER=0
        ;;
        --force-new-config)
            export force_new_config="yes"
        ;;
        *)
            echo "[create-config] Unknown option: $1"
            echo "configuration aborted"
            echo -e "\e[31mFATAL ERROR \e[0m"
            exit 1
        ;;
    esac
    shift
done

#checks config file existance
#this check is not performed if you use --force-new-config
if [[ $force_new_config != "yes" ]] ; then
    if [[ -f "$WTL_CONFIG_FILE" ]] ; then
        echo "[create-config] You already have the '"$WTL_CONFIG_FILE"' file on your directory"
        echo "configuration aborted"
        echo -e "\e[31mFATAL ERROR \e[0m"
        exit 1
    fi
fi

#protocol handling
until [[ ${protocol,,} == "ssh" ]] || [[ ${protocol,,} == "https" ]] ; do
    echo "Do you want to use ssh or https to clone the repository?"
    echo -n "(insert 'https' or 'ssh'): "
    read protocol
done

protocol=${protocol,,}
echo "[create-config] You are using $protocol"

#control if http or ssh
if [[ $protocol == "https" ]] ; then
    WTL_URL="https://github.com/WikiToLearn/WikiToLearn.git"
elif [[ $protocol == "ssh" ]] ; then
    WTL_URL="git@github.com:WikiToLearn/WikiToLearn.git"
fi

#WTL folder handling
if [[ -d "$WTL_REPO_DIR" ]] && [[ $existing_repo != "yes" ]] ; then
    echo "[create-config] $WTL_REPO_DIR directory already exists."
    echo -n "Delete it or move it in another folder, "
    echo "then run again this script if you want to clone  $WTL_REPO_DIR "
    echo "please run $0 with --existing-repo argument"
    echo "configuration aborted"
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
fi

#GitHub token handling
if [[ "$WTL_GITHUB_TOKEN" == "" ]] ; then
    if [[ -f "$WTL_DIR/configs/composer/auth.json" ]] ; then
        echo "[create-config] Using already existing github token in '$WTL_DIR/configs/composer/auth.json'"
        export WTL_GITHUB_TOKEN=$(cat $WTL_DIR/configs/composer/auth.json | python -c 'import json,sys;obj=json.load(sys.stdin);print(obj["config"]["github-oauth"]["github.com"])')
   else
        echo "[create-config] You must insert '--token' parameter followed by a valid token"
        echo "visit https://git.io/vmNUX to learn how to obtain the token"
        echo "configuration aborted"
        echo -e "\e[31mFATAL ERROR \e[0m"
        exit 1
    fi
elif [[ ${WTL_GITHUB_TOKEN:0:1} == "-" ]] ; then
    echo "[create-config] $WTL_GITHUB_TOKEN seems to be a parameter, but I need a github token after '--token'"
    echo "re-execute the script with '--token' parameter followed by the token"
    echo "visit https://git.io/vmNUX to learn how to obtain the token"
    echo "configuration aborted"
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
else

#environtment handling
if [[ ! -f "$WTL_SCRIPTS/environments/$WTL_ENV.sh" ]] ; then
    echo "[create-config] $WTL_ENV is not a valid environment"
    echo "re-execute the script using '-e' followed by one of those valid environments:"
    for script in $( ls $WTL_SCRIPTS/environments/ | grep -v - ) ; do
        echo "$env_options ${script//.sh}"
    done
    echo -e "\e[31mFATAL ERROR \e[0m"
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

_WTL_USER_UID=$(id -u)
_WTL_USER_GID=$(id -g)

#Config file creation
{
cat << EOF
# WikiToLearn Home Configuration version
export WTL_CONFIG_FILE_VERSION=1

# Remote for git repository (initial clone)
export WTL_URL='$WTL_URL'
# Branch to work
export WTL_BRANCH='$WTL_BRANCH'
# automaticaly git checkout before pull
export WTL_BRANCH_AUTO_CHECKOUT=$WTL_BRANCH_AUTO_CHECKOUT

# Domain name to be used
export WTL_DOMAIN_NAME='$WTL_DOMAIN_NAME'
# github token for composer
export WTL_GITHUB_TOKEN='$WTL_GITHUB_TOKEN'

# UID and GID for the user who run WikiToLearn
export WTL_USER_UID=$_WTL_USER_UID
export WTL_USER_GID=$_WTL_USER_GID

# if is 1 we must drop verbosity for log and errors and other stuff
# useful in production env
export WTL_PRODUCTION='$WTL_PRODUCTION'

# the name for the schema we want to run
export WTL_ENV='$WTL_ENV'

export WTL_AUTO_COMPOSER=$WTL_AUTO_COMPOSER

export WTL_MAIL_RELAY_HOST=
export WTL_MAIL_RELAY_USERNAME=
export WTL_MAIL_RELAY_PASSWORD=
export WTL_MAIL_RELAY_FROM_ADDRESS=
export WTL_MAIL_RELAY_STARTTLS=1
EOF
} > $WTL_CONFIG_FILE

if [[ -f "$WTL_CONFIG_FILE" ]] ; then
 echo "[create-config] Configuration file created!"
fi

./load-libs.sh

$WTL_SCRIPTS/make-self-signed-certs.sh
