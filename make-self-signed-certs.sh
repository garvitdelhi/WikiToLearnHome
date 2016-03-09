#!/bin/bash

. ./load-wikitolearn.sh

image="wikitolearn/local-ca:0.1"

docker pull $image

docker inspect $image &> /dev/null
if [[ $? -ne 0 ]] ; then
 echo "Failed to download the "$image
 exit 1
fi

if [[ ! -d $WTL_CERTS ]] ; then
 mkdir ${WTL_CERTS}
 mkdir ${WTL_CERTS}"/easy-rsa/"
fi

docker run -u $WTL_USER_UID:$WTL_USER_GID -v ${WTL_CERTS}"/easy-rsa/":/home/usergeneric/easy-rsa/ -e HOME=/home/usergeneric/ -ti --rm $image
