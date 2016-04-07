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


KEYS_FILE=$WTL_CONFIGS_DIR"gpg-trusted-keys"

#removing keys
echo "Removing keys:"

for key in $(cat $KEYS_FILE); do
    echo "    -Removing pubkey: "$key
    gpg --batch --yes --delete-keys $key &> /dev/null
done
#cleaning the truste-key config file
> $KEYS_FILE

#adding all the keys inside the folder
echo "Adding keys:"

for f in $(find $WTL_TRUSTED_KEYS_REPO -name '*.key'); do
    key=$(gpg $f | grep pub | awk -F '/' '{print $2}')
    key=${key:0:9}
    echo "    -Adding pubkey: "$key
    gpg --import $f &> /dev/null
    #saving the trusted key in config file
    echo $key >> $WTL_CONFIGS_DIR"gpg-trusted-keys"
done
