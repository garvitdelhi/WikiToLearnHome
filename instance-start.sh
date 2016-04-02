#!/bin/bash

cd $(dirname $(realpath $0))

. ./wtl-start.sh
. ./wtl-unuse-instance.sh
. ./wtl-use-instance.sh
. ./wtl-fix-hosts.sh
