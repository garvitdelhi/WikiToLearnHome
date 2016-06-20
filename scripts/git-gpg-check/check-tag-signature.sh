#!/bin/bash
#
# This script checks the signature of the specified TAG.
# If the gpg signature is trusted (inside gpg keyring)
# the script prints the name of the author and returns 0.
##

#moving to WTL repo
cd $WTL_REPO_DIR
TAG=$1
#reading author of the tag
author=$(git tag -v $1 &> /dev/null | grep tagger | awk -F '<' '{print $1}')
#checking signature

if git verify-tag $1 &> /dev/null ; then
  echo "[git-gpg-check] Tag $1 is TRUSTED. $author"
  exit 0
fi
echo "[git-gpg-check] Tag $1 is NOT TRUSTED. $author "
exit 1
