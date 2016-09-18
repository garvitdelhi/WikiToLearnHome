#!/bin/bash
# Load environment variables from const and config file


if [[ $(id -u) -eq 0 ]] || [[ $(id -g) -eq 0 ]] ; then
    echo "[$0] You can't be root. root has too much power."
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
fi

if [[ ! -f "load-libs.sh" ]] ; then
    echo "[load-libs] : The parent script is not running inside the directory that contains load-libs.sh"
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
fi

#call ./const.sh script: load constant environment variables
. ./const.sh

#call $WTL_CONFIG_FILE script: load environment variables defined by current configuration
if [[ ! -f "$WTL_CONFIG_FILE" ]] ; then
    echo "Missing '"$WTL_CONFIG_FILE"' file in the current"
    exit 1
else
    . $WTL_CONFIG_FILE
fi

. ./scripts/wtl-log
. ./scripts/wtl-event

# check the config file version
if [[ "$WTL_CONFIG_FILE_VERSION" != "1" ]] ; then
    wtl-log load-libs.sh 7 CONFIG_VERSION_ERROR "You are running the version $WTL_CONFIG_FILE_VERSION and this requires version 1"
    exit 1
fi

if [[ "$WTL_USER_UID" != $(id -u) ]] ; then
    wtl-log load-libs.sh 7 CONFIG_UID_ERROR "Your UID is not the one in the config file ($WTL_USER_UID != "$(id -u)")"
    exit 1
fi

if [[ "$WTL_USER_GID" != $(id -g) ]] ; then
    wtl-log load-libs.sh 7 CONFIG_GID_ERROR "Your GID is not the one in the config file ($WTL_USER_GID != "$(id -g)")"
    exit 1
fi
test -d $WTL_CACHE || mkdir $WTL_CACHE
