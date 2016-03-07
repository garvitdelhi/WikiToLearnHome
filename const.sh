#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

export WTL_DIR=$(pwd)
export WTL_CONFIG_FILE=$WTL_DIR"/wtl.conf"
export WTL_REPO_DIR=$WTL_DIR"/WikiToLearn"
export WTL_CONFIGS_DIR=$WTL_DIR'/configs/'
export WTL_ARCHIVES=$WTL_DIR"/archives/"
