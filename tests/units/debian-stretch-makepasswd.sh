#!/bin/bash

##############################################################################
## Tests
##############################################################################

function testCommandCheckEntrypoint() {
    echo -e "${LBLUE}function $containerName()${NC}" > "$redirect" 2>&1

    docker run -i --name "$containerName" "$imageName" --help | grep 'makepasswd v' \
        > "$redirect" 2>&1
    rtrn=$?
    assertTrue "Command Check Entrypoint" ${rtrn}
}

function testCommandGeneratePassword() {
    echo -e "${LBLUE}function $containerName()${NC}" > "$redirect" 2>&1

    echo -n "test-password" | docker run -i --name "$containerName" \
        "$imageName" --crypt-md5 --clearfrom=- | awk '{print $2}' \
        > "$redirect" 2>&1
    rtrn=$?
    assertTrue "Command Generate Password" ${rtrn}
}

suite_addTest testCommandCheckEntrypoint
suite_addTest testCommandGeneratePassword
