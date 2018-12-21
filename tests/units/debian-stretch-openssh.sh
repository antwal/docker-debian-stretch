#!/bin/bash

##############################################################################
## Params
##############################################################################

# Use to 0 - create temps folders for tests
mkTmp=0

##############################################################################
## Helper functions
##############################################################################

function getSftpIp() {
    docker inspect -f "{{.NetworkSettings.IPAddress}}" "$1"
}

function runSftpCommands() {
    ip="$(getSftpIp "$1")"
    user="$2"
    shift 2

    commands=""
    for cmd in "$@"; do
        commands="$commands$cmd"$'\n'
    done

    echo "$commands" | sftp \
        -i "/tmp/atmoz_sftp_test_rsa" \
        -oStrictHostKeyChecking=no \
        -oUserKnownHostsFile=/dev/null \
        -b - "$user@$ip" \
        > "$redirect" 2>&1

    status=$?
    sleep 1 # wait for commands to finish
    return $status
}

function waitForServer() {
    containerName="$1"
    echo -n "Waiting for $containerName to open port 22 ..."

    for _ in {1..30}; do
        sleep 1
        ip="$(getSftpIp "$containerName")"
        echo -n "."
        if [ -n "$ip" ] && nc -z "$ip" 22; then
            echo " OPEN"
            return 0;
        fi
    done

    echo " TIMEOUT"
    return 1
}

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
