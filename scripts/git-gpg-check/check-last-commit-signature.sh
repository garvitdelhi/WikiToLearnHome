#!/bin/bash
#
# This script checks the signature of the commit passed as
# argument. If no commit is passed, HEAD is used.
# If the gpg signature is trusted (inside gpg keyring)
# the script prints the name of the author and returns 0.
##

#moving to WTL repo
cd $WTL_REPO_DIR
COMMIT=$1
if [[ $COMMIT == "" ]]; then
    COMMIT="HEAD"
fi
#reading author of last commit
author=$(git show --pretty="Author: %h | %an | %ae" $COMMIT | grep Author)
#checking signature
git verify-commit $COMMIT &> /dev/null
trusted=$?

# if trusted is = 0 then the commit is trusted
if [[ $trusted -gt 0 ]]; then
    echo "[git-gpg-check] Last commit is NOT TRUSTED.    $author "
    exit 1
fi
echo "[git-gpg-check] Last commit is TRUSTED.    $author"
exit 0
