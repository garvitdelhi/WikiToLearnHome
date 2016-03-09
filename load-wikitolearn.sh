#!/bin/bash
# Load config file and ENV variables


cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
  echo "Error changing directory"
  exit 1
fi

. ./const.sh

if [[ ! -f "$WTL_CONFIG_FILE" ]] ; then
  echo "Missing '"$WTL_CONFIG_FILE"' file in the current"
  exit 1
else
  . $WTL_CONFIG_FILE
fi


