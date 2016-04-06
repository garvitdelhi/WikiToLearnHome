#!/bin/bash
#
# Validate signatures on the last commit
##

git log --pretty="format:%G?"  HEAD~1..HEAD | grep -v "G" &> /dev/null

# grep will exit with a non-zero status if no matches are found, which we
# consider a success, so invert it
if [[ $? -gt 0 ]]; then
    echo "[git-gpg-check] Last commit is trusted..."
    exit 0
fi
echo "[git-gpg-check] Last commit is NOT trusted..."
exit 1
