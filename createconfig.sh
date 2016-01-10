#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

for cmd in git docker ; do
 echo -n "Searching for "$cmd"..."
 which $cmd &> /dev/null ; if [[ $? -ne 0 ]] ; then echo "FAIL" ; exit 1 ; else echo "OK" ; fi
done

. ./const.sh

if [[ -f "$W2L_CONFIG_FILE" ]] ; then
 echo "You have the '"$W2L_CONFIG_FILE"' file on your directory"
 exit 1
fi

echo -n "You want to use ssh or https to clone the repository? (https or ssh) "
read proto
case "$proto" in
 "https")
  echo "Using HTTPS"
  W2L_URL="https://github.com/WikiToLearn/WikiToLearn.git"
 ;;
 "ssh")
  echo "Using SSH"
  W2L_URL="git@github.com:WikiToLearn/WikiToLearn.git"
 ;;
 *)
  echo "You must type ssh or https lowercase"
  exit 1
 ;;
esac

if [[ -d "$W2L_REPO_DIR" ]] ; then
 echo "You have '"$W2L_REPO_DIR"' directory in your directory"
 exit 1
fi

{
cat << EOF
export W2L_URL='$W2L_URL'
export W2L_BRANCH='develop'
export W2L_DOMAIN_NAME='tuttorotto.biz'
EOF
} >> $W2L_CONFIG_FILE
