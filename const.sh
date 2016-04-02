#!/bin/bash
#Set the global ENV variables

#cd to current script folder
if [[ ! -f "const.sh" ]] ; then
    echo "[const] : The parent script is not running inside the directory that contains const.sh"
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
fi

#define environment variables
export WTL_DIR=$(pwd)
export WTL_REPO_DIR=$WTL_DIR"/WikiToLearn"
export WTL_CONFIGS_DIR=$WTL_DIR'/configs/'
export WTL_RUNNING=$WTL_DIR"/running/"
export WTL_CERTS=$WTL_DIR"/certs/"
export WTL_CACHE=$WTL_DIR"/cache/"
export WTL_BACKUPS=$WTL_DIR"/backups/"
export WTL_SCRIPTS=$WTL_DIR"/scripts/"

export WTL_CONFIG_FILE=$WTL_CONFIGS_DIR"wtl.conf"
