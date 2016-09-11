#!/bin/bash
#
#
# This script reads the keyfile inside
# $WTL_TRUSTED_KEYS_REPO and add them inside
# gpg keyring as trusted users.
# The trusted keys are saved inside
# $WTL_CONFIGS_DIR/gpg-trusted-keys.
# To remove a key is sufficient to remove the
# keyfile from the folder and execute this script.
#######

if [[ "$WTL_REPO_DIR" != "" ]]
then
    #removing keys
    if test ! -f $WTL_TRUSTED_KEYS_INDEX
    then
        touch $WTL_TRUSTED_KEYS_INDEX
    fi
    for key in $(cat $WTL_TRUSTED_KEYS_INDEX); do
        sed -i '/'$key'/d' $WTL_TRUSTED_KEYS_INDEX
        gpg --batch --yes --delete-keys $key &> /dev/null
    done

    #adding all the keys inside the folder
    if test ! -d $WTL_TRUSTED_KEYS_REPO
    then
        mkdir $WTL_TRUSTED_KEYS_REPO
    fi

    for f in $(find $WTL_TRUSTED_KEYS_REPO -name '*.key'); do
        key=$(gpg $f | grep pub | awk -F '/' '{print $2}')
        key=${key:0:9}
        gpg --import $f &> /dev/null
        #saving the trusted key in config file
        echo $key >> $WTL_TRUSTED_KEYS_INDEX
    done
fi
