#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh


if [[ ! -d $WTL_CONFIGS_DIR ]] ; then
 echo "Migging "$WTL_CONFIGS_DIR" directory"
 exit 1
fi

if [[ $# -eq 0 ]] ; then
 docker ps --format '{{.Names}}' | awk -F"-" '{ print $2 }' | sort | uniq
else
 export WTL_INSTANCE_NAME="wtl-"$1
fi
