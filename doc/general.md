 WikiToLearn Home Documentation
===============================

We assume that you ended up here after reading
[README.mdown](../README.mdown), if this is not the case, we higly
recommend you to do so!

Introduction
-------------

This documentation describes both how to use WTLH to setup a WTL environment
and how WTLH works. The first part will be called *WTLH user guide*,
sice a the WTLH user is a WTL developer, while the second part willbe referred to as *WTLH developer guide*, and is thought to help further WTLH development.

Mediawiki documentation file generation
---------------------------------------

The WTLH repo `doc` folder contains a script, `mediawiki-online.sh`, whose
purpose is converting `.mdown` files to mediawiki code, that can easily be
imported online.

WTLH User Guide: Overview
-------------------------

The developer of the WikiToLearn is supposed to only run `./create-config.sh`
and `./instance.sh` according to the given instructions, since these
bundle all the basic operations that one would perform to the WTL local instance.

### Pages Overview

WTL setup guides

* [Local WTL instance](./wtlh-user-guide/local-wtl-instance.mdown): This guide describes how to locally deploy for the first time a WTL instance, using WTLH.

Detailed script guides: these are a complete and detailed description about how to use `create-config.sh` and `instance.sh`.

* [create-config.sh](./wtlh-user-guide/create-config-doc.mdown)
* [instance.sh](./wtlh-user-guide/instance-doc.mdown)

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

* [Conventions](./wtlh-user-guide/conventions.mdown): This contains coding style conventions for WTLH, and should be read before diving into WTLH code.
* [Recurring](./wtlh-user-guide/recurring.mdown): This describes commands that are contained in more than one script

Detailed script description (this section is still under completion.
Sincerely, I do not know whether it will ever be completed. In case of need do
not esistate to contact the mantainers)

* [const.sh](./wtlh-user-guide/const-doc.mdown):
* [load-libs-doc.sh](./wtlh-user-guide/load-libs-doc.mdown):