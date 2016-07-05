 WikiToLearn Home Documentation
===============================

We assume that you ended up here after reading
`README.md` inside WTLH repo or [WTLH Online Introduction page][WTLH-Online-Intro], if this is not the case, we higly
recommend you to do so!

Introduction
-------------

This documentation describes both how to use WTLH to setup a WTL environment
and how WTLH works. The first part will be called *WTLH user guide*,
sice a the WTLH user is a WTL developer, while the second part will be referred to as *WTLH developer guide*, and is thought to help further WTLH development.

WTLH User Guide: Overview
-------------------------

The developer of the WikiToLearn is supposed to only run `./create-config.sh`
and `./instance.sh` according to the given instructions, since these
bundle all the basic operations that one would perform to the WTL local instance.

### Pages Overview

#### WTL setup guides

* [Local WTL instance](//Local_WikiToLearn_Instance): This guide describes how to locally deploy for the first time a WTL instance, using WTLH.

#### Detailed script guides:
These are a complete and detailed description about how to use `create-config.sh` and `instance.sh`.

* [create-config.sh](//Create_Config_Doc): Creating the confiuration files
* : [instance.sh](//Instance_Doc): Managing the local WTL environment

#### Other Common Operations

Hot to add or update a mediawiki extension

* [Add or update mediawiki extension](//Add_Update_Mediawiki_Extension)

WTLH Developer Guide: Overview
------------------------------

### WTL Flavours

WTL can be run with different purposes, and each of them has its own
peculiarities and requires its own specific configuration and setup.

First of all it can either be run in
*production* mode, for example as in the main production website or as in
the various staging websites, or in *non-production* mode, which can be local
development, or testing new servers and services.

Secondly, WTL environtment can be *basic* , i.e. it runs on a single node (or
host), or it can be spread into multiple georeplicated nodes ( *multiple nodes*
environtment).
We are currently working on georeplication, so this feature is not ready yet.

### Script levels

The scripts are organized in *levels*.

The first level is the *interacion* level
and is constituted by the scripts that the end user should use to interact with
its WTL repo.

The second level is the *atomic* level, and is contituted by single operations
that the user could perform on its WTL repo. These guarantee a finer control
over the WTL repo. Interaction level scripts are composed by combinations of
atomic level sripts.

The third level is the *helper* level, and is constituted by scripts that
are environment-dependent.

The fourh level is the *common* level, which is composed by scripts that
perform operation that are common among at least two helper level scripts from
different environments.

### Pages Overview

First pages to read:

* [Conventions](//Conventions): This contains coding style conventions for WTLH, and should be read before diving into WTLH code.
* [Recurring](//Recurring): This describes commands that are contained in more than one script

Detailed script description (this section is still under completion.
Sincerely, I do not know whether it will ever be completed. In case of need do
not esistate to contact the mantainers)

* [const.sh](//Const_Doc):
* [load-libs-doc.sh](//Load_Libs_Doc):

Documentation webpage generation
--------------------------------

The documentation is at first written in markdown inside the WTLH repo.
The WTLH repo `doc` folder contains a script, `mediawiki-online.sh`, whose
purpose is converting `.md` files to mediawiki code, that is used to generate
the documentation pages on the [meta][meta] website.

This allows to have both online (on the [meta][meta] website) and offline (distributed with the code, inside the WTLH repo) documentation, and that these two instances ofthe doc are kept in sync.

The main documentation creation workflow is:

1. writing the .md files
2. using the script to generate the mediawiki files
3. import those file into [meta][meta]

If you have no access to the WTLH repo but you are willing to contribute to its doc, feel free to edit the online pages, every edit will be reviewed and eventually integrated into offline markdown files if considered valuable.

### How to write links in markdown

Markdown link are to be written keeping in mind that those files are then translated to mediawiki text endthen imported on [meta][meta], hence please use this convention:

```
        [name of the link][<path>]
```

where `<path>` is the relative path from the current folder to the page you want to refer to.

### List of the files/pages

General

* `Readme.md`: [Introduction][WTLH-Online-Intro]
* `general.md`: [WTLH Documentation][WTLH-Doc]

WTLH User guide

* `instance-doc.md`: [Local WTL instance][Local-WTL-instance]
* `local-wtl-instance.md`: [create-config.sh][create-config]
* `create-config-doc.md`: [instance.sh][instance]
* `add-or-update-mediawiki-extension.md` [mediawiki extension][mw-extension]

WTLH dev guide

* `const-doc.md`: [const.sh][const]
* `conventions.md`: [Conventions][conventions]
* `load-libs-doc.md`: [load-libs-doc.sh][load-libs-doc]
* `recurring.md`: [Recurring][recurring]

[WTLH-Online-Intro]: http://meta.wikitolearn.org/WikiToLearn_Home
[WTLH-Doc]: http://meta.wikitolearn.org/WikiToLearn_Home/WikitoLearn_Home_Documentation

[Local-WTL-instance]: http://meta.wikitolearn.org/WikiToLearn_Home/WikitoLearn_Home_Documentation/Local_WikiToLearn_Instance
[create-config]: http://meta.wikitolearn.org/WikiToLearn_Home/WikitoLearn_Home_Documentation/Create_Config_Doc
[instance]: http://meta.wikitolearn.org/WikiToLearn_Home/WikitoLearn_Home_Documentation/Instance_Doc
[mw-extension]: http://meta.wikitolearn.org/WikiToLearn_Home/WikitoLearn_Home_Documentation/Add_Update_Mediawiki_Extension

[conventions]: http://meta.wikitolearn.org/WikiToLearn_Home/WikitoLearn_Home_Documentation/Conventions
[recurring]: http://meta.wikitolearn.org/WikiToLearn_Home/WikitoLearn_Home_Documentation/Recurring
[const]: http://meta.wikitolearn.org/WikiToLearn_Home/WikitoLearn_Home_Documentation/Const_Doc
[load-libs-doc]: http://meta.wikitolearn.org/WikiToLearn_Home/WikitoLearn_Home_Documentation/Load_Libs_Doc


[meta]: https://meta.wikitolearn.org
