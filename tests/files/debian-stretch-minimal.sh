#!/bin/bash

##############################################################################
## Params
##############################################################################

# Use to 0 - create temps folders for tests
# mkTmp=0

##############################################################################
## Tests
##############################################################################

function testCommandInternalSyslog() {
    echo -e "${COLOR}function $containerName()${NC}" > "$redirect" 2>&1

    params="--name \"$containerName\" \
--env \"DEBBASE_SYSLOG=internal\" \
--entrypoint=\"/usr/local/bin/boot-debian-base\" \
--detach \"$imageName\""

    runContainer "$params"
    assertTrue "runContainer" $?

    check="$(docker exec $containerName \
        bash -c "cat /etc/syslog.conf")"

    echo $check | grep '/var/log' >/dev/null
    rtrn=$?
    assertTrue "Command Internal Syslog" ${rtrn}
}

function testCommandTimezone() {
    echo -e "${COLOR}function $containerName()${NC}" > "$redirect" 2>&1

    params="--name \"$containerName\" \
--env \"DEBBASE_TIMEZONE=Europe/Rome\" \
--entrypoint=\"/usr/local/bin/boot-debian-base\" \
--detach \"$imageName\""

    runContainer "$params"
    assertTrue "runContainer" $?

    check="$(docker exec $containerName \
        bash -c "cat /etc/timezone")"

    echo $check | grep 'Europe/Rome' >/dev/null
    rtrn=$?
    assertTrue "Command Timezone" ${rtrn}
}

#function testComposeImageTimezone {
    # docker-compose -f tests/docker/debian-stretch-minimal-image.yml up -d --build
    # docker exec testComposeImageTimezone bash -c "cat /etc/timezone"
    # docker exec -it testComposeImageTimezone /bin/bash
#}

suite_addTest testCommandInternalSyslog
suite_addTest testCommandTimezone
