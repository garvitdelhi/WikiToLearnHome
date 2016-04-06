#!/bin/bash
#
# This script checks the signature of the last commit.
# If the gpg signature is trusted (inside gpg keyring)
# the script prints the name of the author and returns 0.
##


#reading author of last commit
author=$(git log --pretty="format:%an %ae"  HEAD~1..HEAD)
#checking signature
trusted=$(git log --pretty="format:%G?"  HEAD~1..HEAD)

# grep will exit with a non-zero status if no matches are found, which we
# consider a success, so invert it
if [[ $trusted == 'G' ]]; then
    echo "[git-gpg-check] Last commit is TRUSTED.   Author: $author "
    exit 0
fi
echo "[git-gpg-check] Last commit is NOT TRUSTED.   Author: $author"
exit 1
