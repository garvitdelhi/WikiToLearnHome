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

grep UUID $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php" | grep $UUID &> /dev/null || {

cat << EOF >> $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php"
<?php /* UUID : $UUID */
\$wgReadOnly = '$MSG'; /* $UUID */
/* $UUID */ ?>
EOF

}
