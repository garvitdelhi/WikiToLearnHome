#!/bin/bash
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "mw-export-struct-wikipages.sh" ]] ; then
    echo "Wrong way to execute mw-export-struct-wikipages.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh

. $WTL_SCRIPTS/environments/${WTL_ENV}.sh

# The script will download only local wikipages, right now there is no point in downloading ALL_LANGUAGES
# USAGE: $0 [dryrun (default)|execute] [domain (default wikitolearn.org)]
# EXAMPLE: $0 execute wikitolearn.org
# EXAMPLE: $0 dryrun
# wtl-event MW_STRUCT_PAGES_GET_LANG_LIST
langlist=$(cat $WTL_WORKING_DIR/databases.conf | sed 's/wikitolearn//g' | grep -v shared)

langlist_str=""
for l in $langlist
do
  langlist_str=$langlist_str" "$l
done

dryrun=${1:-"dryrun"} #pass 'execute' as first param to really execute it
domain=${2:-"wikitolearn.org"}

folderStatus=$(git --git-dir=$WTL_WORKING_DIR/.git --work-tree=$WTL_WORKING_DIR status --porcelain struct-wikipages | wc -l)
if [[ $folderStatus -gt 0 ]]
then
    echo "struct-wikipages directory in dirty status. Please commit or checkout your changes before running this script."
    exit 1
fi

if [ "$dryrun" == "dryrun" ]
then
    echo "++++++++++++++++++++++++++++++++++++++"
    echo "+ Running in dryrun mode, pass 'execute' to really overwrite"
    echo "++++++++++++++++++++++++++++++++++++++"
fi

# wtl-event MW_STRUCT_PAGES_LANG_LIST $langlist_str
for lang in $langlist; do
    #wtl-event MW_STRUCT_PAGES_RUN_LANG $lang
    if test -d $WTL_WORKING_DIR/struct-wikipages/$lang/ && [[ $(ls $WTL_WORKING_DIR/struct-wikipages/$lang/  | wc -l) -gt 0 ]]
    then
        for f in $WTL_WORKING_DIR/struct-wikipages/$lang/*
        do
            filename=$(basename $f)

            echo "Downloading $filename from $lang.$domain"
            wikitext=$(curl -sL "$lang.$domain/api.php?action=parse&page=$filename&prop=wikitext&format=json" | python3 -c 'import json,sys;obj=json.load(sys.stdin);print(obj["parse"]["wikitext"]["*"]) if "parse" in obj else print(404);')
            if [ "$wikitext" == "404" ]
            then
                echo "$filename does not exist on $lang.$domain"
            else
                if [ "$wikitext" == "$(cat $f)" ]
                then
                    echo "Remote $filename is the same as local $filename"
                else
                    if [ "$dryrun" == "execute" ]
                    then
                        echo "Remote $filename OVERWRITING local copy"
                        echo $wikitext > $f
                    else
                        echo "[DRY RUN] $filename WILL OVERWRITE local copy"
                    fi
                fi
            fi
            echo ""
        done
    fi
done
