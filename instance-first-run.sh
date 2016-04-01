#!/bin/bash

cd $(dirname $(realpath $0))

. ./wtl-create.sh
. ./wtl-start.sh
. ./wtl-backup-restore.sh WikiToLearn/DeveloperDump/
. ./wtl-unuse-instance.sh
. ./wtl-use-instance.sh
. ./wtl-update-db.sh
