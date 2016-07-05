instance.sh
------------

### Description

This script is the core of WTLH, since its arguments call atomic layer scripts
in the correct order to perform the desired operation on the WTL instance.

### Synopsis

```{.bash}
./create-config.sh [first-run | create | start | stop | delete | delete-full | delete-volumes | update-docker-container | devdump-import | devdump-export | download | fix-hosts | update-home | staging | release-do | release-clean | help]
```

### Use Cases

We give some examples, based on different situations we think this script
may be used in. We would really like to hear from you in order to
make this list as exhaustive as possible!

* First time you run the local environment
        `./instance-sh first-run`

* Close the local instance (should be done before shutdown/restart)
        `./instance.sh stop`

* Start the local instance, assuming you have already have done a completed
    configure and start with `./instance.sh first run`, and then stopped
    the instance with `./instance.sh stop`
        `./instance.sh start`

* Update WTLH
        `./instance.sh update-home`

* Update WTL, Mediawiki and Mediawiki extensions
        `./instance.sh download`

* Update docker images and containers
        `./instance.sh update-docker-container`

* Full update: WTL and submodules, Mediawiki and extensions, docker images and      
    containers
        `./instance.sh update-code-and-db`


### Options

This script has to be run with only one argument. If you do not pass any
argument, it automatically assumes that you passed `help`.

Now follows a detailed description of what each parameter do.

* `help`
        cat doc/wtlh-user-guide/instance-doc.mdown

Creating and starting the environment

* `create`
        $WTL_SCRIPTS/create.sh

    This creates the WTL webserver docker container, linking to it all the
    others containers, accordingly to the environment specifications.

* `start`
        $WTL_SCRIPTS/start.sh
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/use-instance.sh
        $WTL_SCRIPTS/fix-hosts.sh

    * Starts the webserver docker container
    * stops and remove the haproxy docker container
    * creates and starts haproxy docerk container again
    * then fixes the hosts in parsoid ocg and restbase docker containers

* `first-run`
        $WTL_SCRIPTS/download-all.sh
        $WTL_SCRIPTS/download-mediawiki-extensions.sh
        $WTL_SCRIPTS/create.sh
        $WTL_SCRIPTS/start.sh
        $WTL_SCRIPTS/backup-restore.sh $WTL_REPO_DIR/DeveloperDump/
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/use-instance.sh
        $WTL_SCRIPTS/update-db.sh

    Do everything that is needed at the first run of WTL instance:
    * pull docker images
    * git checkuot and pull of WTL repo
    * git submodule sync and submodule update
    * Download Mediawiki extensions
    * create docker containers
    * start docker containers
    * restores devdump database
    * stops and remove the haproxy docker container
    * creates and starts haproxy docerk container again
    * update-db

Stopping and deleting the environment

* `stop`
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/stop.sh

    * stops and remove the haproxy docker container
    * stops every current version WTL docker

* `delete`
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/stop.sh
        $WTL_SCRIPTS/delete.sh

    Same as `stop` (#FIXME) , then
    * delete every curent version WTL docker container

* `delete-volumes`
        $WTL_SCRIPTS/delete-volumes.sh

    * delete every current version WTL docker volume

* `delete-full`
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/stop.sh
        $WTL_SCRIPTS/delete.sh
        $WTL_SCRIPTS/delete-volumes.sh

     This is like `delete` + `delete-volumes`

Mantainance

* `fix-hosts`
        $WTL_SCRIPTS/fix-hosts.sh

    fixes the hosts in parsoid ocg and restbase docker containers

Update Procedures

* `update-home`
        $WTL_SCRIPTS/update-home.sh

    Update WTLH git repo

* `download`
        $WTL_SCRIPTS/download-code.sh
        $WTL_SCRIPTS/download-mediawiki-extensions.sh

    * git checkuot and pull of WTL repo
    * git submodule sync and submodule update
    * Download Mediawiki extensions

* `update-docker-container`
        $WTL_SCRIPTS/pull-images.sh
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/stop.sh
        $WTL_SCRIPTS/delete.sh
        $WTL_SCRIPTS/create.sh
        $WTL_SCRIPTS/start.sh
        $WTL_SCRIPTS/use-instance.sh
        $WTL_SCRIPTS/fix-hosts.sh

    * download the new docker images
    * stop and delete the current containers
    * create and start the new containers (based on the new images)
    * fix the hosts in ocg restbase and parsoid containers

* `update-code-and-db`
        $WTL_SCRIPTS/download-code.sh
        $WTL_SCRIPTS/download-mediawiki-extensions.sh
        $WTL_SCRIPTS/pull-images.sh
        $WTL_SCRIPTS/unuse-instance.sh
        $WTL_SCRIPTS/stop.sh
        $WTL_SCRIPTS/delete.sh
        $WTL_SCRIPTS/create.sh
        $WTL_SCRIPTS/start.sh
        $WTL_SCRIPTS/use-instance.sh
        $WTL_SCRIPTS/fix-hosts.sh
        $WTL_SCRIPTS/update-db.sh

    This command makes a full update of the WTL local instance.
    It updates WTL repo, the submodules it uses

    * same as `./instance.sh download`
    * same as `./isntance.sh update-docker-container`
    * update database

Database Management

* `devdump-import`
        $WTL_SCRIPTS/backup-restore.sh $WTL_REPO_DIR/DeveloperDump/
        $WTL_SCRIPTS/update-db.sh

        Import a test database, contained in ./DeveloperDump

* `devdump-export`
        $WTL_SCRIPTS/backup-do.sh
        $WTL_SCRIPTS/copy-last-backup-to-devdump.sh

        Export the current database to ./DeveloperDump

#### Production and Staging Commands

These are used in staging and production environments, hence are not intended
tobe run in a local-dev environment

* `release-do`

* `release-clean`

* `staging`
    same as `./instance.sh release-do` and then `./instance.sh release-clean`
