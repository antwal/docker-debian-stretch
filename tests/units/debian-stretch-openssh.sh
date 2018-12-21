#!/bin/bash

##############################################################################
## Params
##############################################################################

# Use to 0 - create temps folders for tests
mkTmp=0

##############################################################################
## Helper functions
##############################################################################

function generateRSA() {
    # Generate temporary ssh keys for testing
    if [ ! -f "${buildDir}/build/test_rsa" ]; then
        ssh-keygen -t rsa -f "${buildDir}/build/test_rsa" -N '' > "$redirect" 2>&1
    fi

    # Private key can not be read by others (sshd will complain)
    chmod go-rw "${buildDir}/build/test_rsa"
}

function runSftpCommands() {
    ip="$(getContainerIp "$1")"

    user="$2"
    shift 2

    commands=""
    for cmd in "$@"; do
        commands="$commands$cmd"$'\n'
    done

    echo "$commands" | sftp \
        -i "${buildDir}/build/test_rsa" \
        -oStrictHostKeyChecking=no \
        -oUserKnownHostsFile=/dev/null \
        -b - "$user@$ip" \
        > "$redirect" 2>&1

    status=$?
    sleep 1 # wait for commands to finish

    return $status
}

##############################################################################
## Tests
##############################################################################

function testRunContainer() {
    echo -e "${COLOR}function $containerName()${NC}" > "$redirect" 2>&1

    params="-i --name \"$containerName\" \
-d \"$imageName\""

    runContainer "$params"
    assertTrue "runContainer" $?

    logs="$(docker logs $containerName)"

    echo "$logs" | grep "SSH server disabled;"
    assertTrue "SSH Disabled" $?
}

function testListenSSH() {
    echo -e "${COLOR}function $containerName()${NC}" > "$redirect" 2>&1

    docker run --name "$containerName" --env "DEBBASE_SSH=enabled" -p 2022:22 \
        -d "$imageName" > "$redirect" 2>&1

    waitForServer "$containerName" "2022"
    assertTrue "waitForServer" $?
}

function testUsersConf() {
    echo -e "${COLOR}function $containerName()${NC}" > "$redirect" 2>&1

    params="--name \"$containerName\" --env \"DEBBASE_SSH=enabled\" \
-p 2022:22 -v \"$testDir/files/users.conf:/etc/openssh/users.conf:ro\" \
-d \"$imageName\""

    runContainer "$params"
    assertTrue "runContainer" $?

    # docker run --name "$containerName" --env "DEBBASE_SSH=enabled" -p 2022:22 \
    #     -v "$testDir/files/users.conf:/etc/openssh/users.conf:ro" \
    #     -d "$imageName" > "$redirect" 2>&1

    waitForServer "$containerName" "2022"
    assertTrue "waitForServer" $?

    docker exec "$containerName" id user1 > /dev/null
    assertTrue "user1" $?

    id="$(docker exec "$containerName" id user5)"

    echo "$id" | grep -q 'uid=9550('
    assertTrue "custom UID" $?

    echo "$id" | grep -q 'gid=65534('
    assertTrue "custom GID" $?

    assertEquals "uid=9550(user5) gid=65534(nogroup) groups=65534(nogroup)" "$id"
}

function testCommandCreateUsers() {
    docker run --name "$containerName" --env "DEBBASE_SSH=enabled" -p 2022:22 \
        -d "$imageName" > "$redirect" 2>&1

    waitForServer "$containerName" "2022"
    assertTrue "waitForServer" $?

    docker exec "$containerName" create-ssh-user "create1:" > /dev/null
    assertTrue "user created" $?

    docker exec "$containerName" id create12414 > /dev/null
    assertTrue "check user created" $?
}

# function testEnvCreateUsers() {
#
# }
#
# function testBindMountDirScript() {
#
# }

suite_addTest testRunContainer
suite_addTest testListenSSH
suite_addTest testUsersConf
