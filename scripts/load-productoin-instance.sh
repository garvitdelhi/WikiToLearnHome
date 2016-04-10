#/bin/bash
if docker inspect wikitolearn-haproxy &> /dev/null ; then
    export WTL_INSTANCE_NAME=$(docker inspect -f '{{index .Config.Labels "WTL_INSTANCE_NAME"}}' wikitolearn-haproxy)
    export WTL_WORKING_DIR=$(docker inspect -f '{{index .Config.Labels "WTL_WORKING_DIR"}}' wikitolearn-haproxy)
else
    if [[ $(basename $0) == "bash" ]] ; then
        echo "Error: unable to find the haproxy docker"
    else
        wtl-log backup-auto-delete-production.sh 0 MISSING_HA_PROXY "Production backup-auto-delete: missing docker wikitolearn-haproxy"
        exit 1
    fi
fi

