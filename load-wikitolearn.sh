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


if [[ "$WTL_CONFIG_FILE_VERSION" != "1" ]] ; then
 echo "Wrong config file version. You are running the version $WTL_CONFIG_FILE_VERSION and this requires version 1"
 exit 1
fi

if [[ "$WTL_USER_UID" != $(id -u) ]] ; then
 echo "Your UID is not the one in the config file ($WTL_USER_UID != "$(id -u)")"
 exit 1
fi

if [[ "$WTL_USER_GID" != $(id -g) ]] ; then
 echo "Your GID is not the one in the config file ($WTL_USER_GID != "$(id -g)")"
 exit 1
fi
