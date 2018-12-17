#!/bin/bash

##############################################################################
## Tests
##############################################################################

function testRunInternalSyslog() {
    cid="$(docker run --name "$containerName" \
        --env "DEBBASE_SYSLOG=internal" \
        --entrypoint="/usr/local/bin/boot-debian-base" \
        --detach "$imageName")"
    assertTrue "Run with Internal Syslog" $?


}

suite_addTest testRunInternalSyslog
