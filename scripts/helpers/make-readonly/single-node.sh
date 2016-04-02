#!/bin/bash

MSG='This wiki is currently being upgraded to a newer software version.'

if [[ "$@" != "" ]] ; then
    MSG="$@"
fi

UUID=$(echo $MSG | sha1sum | awk '{ print $1 }')

grep UUID $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php" | grep $UUID &> /dev/null || {

cat << EOF >> $WTL_WORKING_DIR"/LocalSettings.d/wgReadOnly.php"
<?php /* UUID : $UUID */
\$wgReadOnly = '$MSG'; /* $UUID */
/* $UUID */ ?>
EOF

}
