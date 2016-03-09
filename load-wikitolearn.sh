#!/bin/bash
# Load environment variables from const and config file

#cd to current script folder
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
  echo "Error changing directory"
  exit 1
fi

#call ./const.sh script: load constant environment variables
. ./const.sh

#call $WT__CONFIG_FILE script: load environment variables defined by current configuration 
if [[ ! -f "$WTL_CONFIG_FILE" ]] ; then
  echo "Missing '"$WTL_CONFIG_FILE"' file in the current"
  exit 1
else
  . $WTL_CONFIG_FILE
fi


