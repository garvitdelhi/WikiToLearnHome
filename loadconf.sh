#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./const.sh


if [[ ! -f "$W2L_CONFIG_FILE" ]] ; then
 echo "Missing '"$W2L_CONFIG_FILE"' file on your directory"
 exit 1
fi


. $W2L_CONFIG_FILE
