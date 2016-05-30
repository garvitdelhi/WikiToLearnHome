#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "mw-dumps-from-production.sh" ]] ; then
    echo "Wrong way to execute mw-dumps-from-production.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh

# This scirpt must download the page from production site and save localy
# this is the example command from mediawiki doc
# curl -d "&action=submit&pages=$(cat title-list | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g' )" http://en.wikipedia.org/w/index.php?title=Special:Export -o "somefilename.xml"
#
TMP_DIR=`mktemp -d`
cd $TMP_DIR

if [[ $# -lt 3 ]] ; then
    echo "This command must be runned as "$0" <langcode> <output name> <page1> <page2> ... <pageN>"
    exit 1
fi
lang=$1
output=$2
shift
{
for pag in $@
do
    echo $pag
done
} &> pages
curl -d "&action=submit&pages=$(cat pages | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g' )" http://$lang.wikitolearn.org/index.php?title=Special:Export -o "$WTL_MW_DUMPS_DOWNLOAD/$output.xml"

cd
rm -Rf $TMP_DIR
