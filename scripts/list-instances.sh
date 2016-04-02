#!/bin/bash
# Print active instances

docker ps --format '{{.Names}}' | grep ^wtl- | awk -F"-" '{ print $2 }' | sort | uniq
