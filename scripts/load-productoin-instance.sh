#/bin/bash
if docker inspect wikitolearn-haproxy &> /dev/null ; then
    export WTL_INSTANCE_NAME=$(docker inspect -f '{{index .Config.Labels "WTL_INSTANCE_NAME"}}' wikitolearn-haproxy)
    export WTL_WORKING_DIR=$(docker inspect -f '{{index .Config.Labels "WTL_WORKING_DIR"}}' wikitolearn-haproxy)
else
    if [[ $(basename $0) == "bash" ]] ; then
        wtl-event MISSING_HA_PROXY
    else
        wtl-event MISSING_HA_PROXY
        exit 1
    fi
fi
