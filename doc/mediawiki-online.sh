#!/bin/bash

# simple script that converts the markdown documentation pages to mediawiki,
# that are then imported into meta.wikitolearn.org

# set the name of the folder containing the mediawiki exported files
mediawiki_page_folder="mediawiki-online.d"

case $1 in
    make)
        # if the folder is not present, it creates it and creates the
        # .placeholder file needed not to have git ignore the empty folder
        if [[ ! -d $mediawiki_page_folder ]] ; then
            mkdir $mediawiki_page_folder
            touch $mediawiki_page_folder/.placeholder
        fi

        # it creates the folders wtlh-*-guide inside $mediawiki_page_folder
        for i in wtlh-* ; do
            if [[ ! -d $mediawiki_page_folder/$i ]] ; then
                mkdir $mediawiki_page_folder/$i
                touch $mediawiki_page_folder/$i/.placeholder
            fi
        done

        echo -n "Converting: README.md ..."
        pandoc -r markdown -t mediawiki \
            -o $mediawiki_page_folder/wtlh-intro.mwiki ../README.md
        echo "Done!"

        # converts all the *.mdown files into mediawiki files
        for i in *.md */*.md; do
            echo -n "Converting: $i ..."
            pandoc -r markdown -t mediawiki \
                -o $mediawiki_page_folder/${i%.*}.mwiki $i
            echo "Done!"
        done

    ;;
    clean)
        rm -rfv $mediawiki_page_folder/*
        touch $mediawiki_page_folder/.placeholder
    ;;
    *)
        echo "empty or wrong argument!"
        echo "you are supposed to use '$0 make' or '$0 clean'"
        exit
    ;;
esac
