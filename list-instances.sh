#!/bin/bash
# Print active instances

docker ps --format '{{.Names}}' | awk -F"-" '{ print $2 }' | sort | uniq