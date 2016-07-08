#!/bin/bash
. ./load-libs.sh

MSG='This wiki is currently being upgraded to a newer software version.'

if [[ "$@" != "" ]] ; then
    MSG="$@"
fi

UUID=$(echo $MSG | sha1sum | awk '{ print $1 }')
if test ! -f $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php" ; then
    touch $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php"
fi

sed -i '/'$UUID'/d' $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php"

if [[ $(cat $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php" | wc -l) -eq 0 ]] ; then
    rm -v $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php"
fi
