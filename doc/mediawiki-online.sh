#!/bin/bash

# simple script that converts the markdown documentation pages to mediawiki,
# that are then imported into meta.wikitolearn.org

# set the name of the folder containing the mediawiki exported files
mediawiki_page_folder="mediawiki-online.d"

case $1 in
    make)
        # if the folder is not present, it creates it and creates the
        #.placeholder file needed not to have git ignore the empty folder
        if [[ ! -d $mediawiki_page_folder ]] ; then
            mkdir $mediawiki_page_folder
            touch $mediawiki_page_folder/.placeholder
        fi

        for i in *.mdown ; do
            pandoc -r markdown -t mediawiki \
                -o $mediawiki_page_folder/${i%.*}.mwiki $i
            echo "Converted: $i"
        done
    ;;
    clean)
        rm -rfv $mediawiki_page_folder/*.mwiki
    ;;
    *)
        echo "empy argument!"
        echo "you are supposed to use $0 make or $0 clean"
        exit
    ;;
esac
