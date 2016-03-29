#!/bin/bash
# Load environment variables from const and config file

if [[ ! -f "load-wikitolearn.sh" ]] ; then
    echo "[load-wikitolearn] : The parent script is not running inside the directory that contains load-wikitolearn.sh"
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

# create the function to log messages
# first  parameter must be the script name
# second parameter must be the log level (0=CRITICAL,1=NORMAL,2=DEBUG,3=TRACE)
# third  parameter must be the id of the event (must be unique across all scripts)
# evrything else is the log message
wtl-log () {
    EXIT_STATUS=$?
    SCRIPT_NAME=$1 ; shift
    LOG_LEVEL=$1   ; shift
    EVENT_ID=$1    ; shift
    LOG_MSG=$@
    if [[ $LOG_LEVEL -eq 0 ]] ; then
        echo -e -n "\e[31mCRITICAL\e[0m"
        echo -n ": "
    fi
    echo $LOG_MSG
}

# check the config file version
if [[ "$WTL_CONFIG_FILE_VERSION" != "1" ]] ; then
    echo "Wrong config file version."
    wtl-log load-wikitolearn.sh 0 CONFIG_VERSION_ERROR "You are running the version $WTL_CONFIG_FILE_VERSION and this requires version 1"
    exit 1
fi

if [[ "$WTL_USER_UID" != $(id -u) ]] ; then
    wtl-log load-wikitolearn.sh 0 CONFIG_UID_ERROR "Your UID is not the one in the config file ($WTL_USER_UID != "$(id -u)")"
    exit 1
fi

if [[ "$WTL_USER_GID" != $(id -g) ]] ; then
    wtl-log load-wikitolearn.sh 0 CONFIG_GID_ERROR "Your GID is not the one in the config file ($WTL_USER_GID != "$(id -g)")"
    exit 1
fi
