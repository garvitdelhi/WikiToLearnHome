#!/bin/bash
#Set the global ENV variables

#cd to current script folder
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

#define environment variables
export WTL_DIR=$(pwd)
export WTL_REPO_DIR=$WTL_DIR"/WikiToLearn/"
export WTL_CONFIGS_DIR=$WTL_DIR'/configs/'
export WTL_RUNNING=$WTL_DIR"/running/"
export WTL_CERTS=$WTL_DIR"/certs/"
export WTL_CACHE=$WTL_DIR"/cache/"

export WTL_CONFIG_FILE=$WTL_CONFIGS_DIR"wtl.conf"
