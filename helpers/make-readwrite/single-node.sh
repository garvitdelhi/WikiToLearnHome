#!/bin/bash

MSG='This wiki is currently being upgraded to a newer software version.'

if [[ "$@" != "" ]] ; then
    MSG="$@"
fi

UUID=$(echo $MSG | sha1sum | awk '{ print $1 }')

sed -i '/'$UUID'/d' $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php"

if [[ $(cat $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php" | wc -l) -eq 0 ]] ; then
    rm -v $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php"
fi
