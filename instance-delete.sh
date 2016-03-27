#!/bin/bash

cd $(dirname $(realpath $0))

. ./wtl-stop.sh
. ./wtl-delete.sh
. ./wtl-unuse-instance.sh
