#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./const.sh


if [[ ! -f "$WTL_CONFIG_FILE" ]] ; then
 echo "Missing '"$WTL_CONFIG_FILE"' file on your directory"
 exit 1
fi


. $WTL_CONFIG_FILE
