#!/bin/bash
#
# This script checks the signature of the last commit.
# If the gpg signature is trusted (inside gpg keyring)
# the script prints the name of the author and returns 0.
##

curr=$(pwd) #saving current directory
#moving to WTL repo
cd $WTL_REPO_DIR
#reading author of last commit
author=$(git log --pretty="format: | %h | %an | %ae"  HEAD~1..HEAD)
#checking signature
trusted=$(git log --pretty="format:%G?"  HEAD~1..HEAD)
#returning to previous directory
cd $curr

# grep will exit with a non-zero status if no matches are found, which we
# consider a success, so invert it
if [[ $trusted == 'G' ]]; then
    echo "[git-gpg-check] Last commit is TRUSTED $author "
    exit 0
fi
echo "[git-gpg-check] Last commit is NOT TRUSTED $author"
exit 1
