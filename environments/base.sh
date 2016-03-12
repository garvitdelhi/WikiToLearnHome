#!/bin/bash
echo "Base WikiToLearn Env" 

if [[ "$WTL_DOCKER_MYSQL" == "" ]] ; then
 echo "You need mysql variable"
 exit 1
fi

#export WTL_DOCKER_MEMCACHED="memcached:1.4.24"
#export WTL_DOCKER_OCG="wikitolearn/ocg:0.9.2"
#export WTL_DOCKER_WEBSRV="wikitolearn/websrv:0.12.1"
#export WTL_DOCKER_HAPROXY="wikitolearn/haproxy:0.6.1"
#export WTL_DOCKER_PARSOID="wikitolearn/parsoid:0.1.1"
#export WTL_DOCKER_MATHOID="wikitolearn/mathoid:0.2.2"

export WTL_HELPER_CREATE="mount-repo-single-node"
export WTL_HELPER_START="start-single-node"
export WTL_HELPER_RESTORE_BACKUP="single-node"
