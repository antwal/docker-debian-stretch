#!/bin/bash

##############################################################################
## Params
##############################################################################

# 0 - create temps folders for tests - comment for disable
mkTmp=0

port=22
argport=()

if [ "${kernel}" == "Darwin" ]; then
    port=2022
    argport=(--publish "2022:22")
fi

##############################################################################
## Helper functions
##############################################################################

function generateRSA() {
    # Generate temporary ssh keys for testing
    if [ ! -f "$rootDir/$containerTmpDir/ssh_host_rsa_key" ]; then
        ssh-keygen -t rsa -b 4096 -f "$rootDir/$containerTmpDir/ssh_host_rsa_key" -N '' \
            > "$redirect" 2>&1
    fi

    # Private key can not be read by others (sshd will complain)
    chmod go-rw "$rootDir/$containerTmpDir/ssh_host_rsa_key"
}

function runSftpCommands() {
    ip="$(getContainerIp "$1")"

    user="$2"
    shift 2

    commands=""
    for cmd in "$@"; do
        commands="$commands$cmd"$'\n'
    done

    if [ "${kernel}" == "Darwin" ]; then
        echo "$commands" | sftp \
            -i "$containerTmpDir/ssh_host_rsa_key" \
            -oStrictHostKeyChecking=no \
            -oUserKnownHostsFile=/dev/null \
            -P 2022 -b - "$user@0.0.0.0" \
            > "$redirect" 2>&1
    else
        echo "$commands" | sftp \
            -i "$containerTmpDir/ssh_host_rsa_key" \
            -oStrictHostKeyChecking=no \
            -oUserKnownHostsFile=/dev/null \
            -b - "$user@$ip" \
            > "$redirect" 2>&1
    fi

    status=$?
    sleep 1 # wait for commands to finish

    return $status
}

##############################################################################
## Tests
##############################################################################

function testRunContainer() {
    echo -e "${LBLUE}function $containerName()${NC}" > "$redirect" 2>&1

    params="-i --name \"$containerName\" \
-d \"$imageName\""

    runContainer "$params"
    assertTrue "runContainer" $?

    logs="$(docker logs "$containerName")"

    echo "$logs" | grep "SSH server disabled;"
    assertTrue "SSH Disabled" $?
}

function testListenSSH() {
    echo -e "${LBLUE}function $containerName()${NC}" > "$redirect" 2>&1

    docker run --name "$containerName" --env "DEBBASE_SSH=enabled" "${argport[@]}" \
        -d "$imageName" > "$redirect" 2>&1

    waitForServer "$containerName" "$port"
    assertTrue "waitForServer" $?
}

function testEnableRoot() {
    echo -e "${LBLUE}function $containerName()${NC}" > "$redirect" 2>&1

    docker run --name "$containerName" --env "DEBBASE_SSH=enabled" \
        --env "ROOT_SSH=enabled" "${argport[@]}" \
        -d "$imageName" > "$redirect" 2>&1

    waitForServer "$containerName" "$port"
    assertTrue "waitForServer" $?

    docker exec "$containerName" id root > /dev/null
    assertTrue "user root" $?
}

function testUsersConf() {
    echo -e "${LBLUE}function $containerName()${NC}" > "$redirect" 2>&1

#     params="--name \"$containerName\" --env \"DEBBASE_SSH=enabled\" \
# -v \"$testDir/files/users.conf:/etc/openssh/users.conf:ro\" \
# -d \"$imageName\""
#
#     runContainer "$params"
#     assertTrue "runContainer" $?

    docker run --name "$containerName" --env "DEBBASE_SSH=enabled" "${argport[@]}" \
        -v "$testDir/files/users.conf:/etc/openssh/users.conf:ro" \
        -d "$imageName" > "$redirect" 2>&1

    waitForServer "$containerName" "$port"
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
    echo -e "${LBLUE}function $containerName()${NC}" > "$redirect" 2>&1

    docker run --name "$containerName" --env "DEBBASE_SSH=enabled" "${argport[@]}" \
        -d "$imageName" > "$redirect" 2>&1

    waitForServer "$containerName" "$port"
    assertTrue "waitForServer" $?

    docker exec "$containerName" create-ssh-user "create1:" > /dev/null
    assertTrue "user created" $?

    docker exec "$containerName" id create1 > /dev/null
    assertTrue "check user created" $?
}

function testEnvCreateUsers() {
    echo -e "${LBLUE}function $containerName()${NC}" > "$redirect" 2>&1

    docker run --name "$containerName" -e "DEBBASE_SSH=enabled" \
        -e "SSH_USERS=userenv1: userenv2:" "${argport[@]}" \
        -d "$imageName" > "$redirect" 2>&1

    waitForServer "$containerName" "$port"
    assertTrue "waitForServer" $?

    docker exec "$containerName" id userenv1 > /dev/null
    assertTrue "userenv1" $?

    docker exec "$containerName" id userenv2 > /dev/null
    assertTrue "userenv2" $?
}

function testSFTPServer() {
    echo -e "${LBLUE}function $containerName()${NC}" > "$redirect" 2>&1

    generateRSA

    docker run --name "$containerName" --env "DEBBASE_SSH=enabled" \
        --env "SSH_USERS=usftp1:" "${argport[@]}" \
        -v "$rootDir/$containerTmpDir/ssh_host_rsa_key.pub:/home/usftp1/.ssh/keys/id_rsa.pub:ro" \
        -d "$imageName" > "$redirect" 2>&1

    waitForServer "$containerName" "$port"
    assertTrue "waitForServer" $?

    runSftpCommands "$containerName" "usftp1" \
        "cd /home/usftp1" \
        "mkdir test" \
        "cd test" \
        "mkdir subtest" \
        "exit"
    assertTrue "runSftpCommands" $?

    docker exec "$containerName" test -d /home/usftp1/test/
    assertTrue "dir write access" $?

    docker exec "$containerName" test -d /home/usftp1/test/subtest
    assertTrue "subtest write access" $?
}

# function testRSACertificate() {
#     echo -e "${LBLUE}function $containerName()${NC}" > "$redirect" 2>&1
#
#     generateRSA
#
#     docker run --name "$containerName" --env "DEBBASE_SSH=enabled" \
#         --env "SSH_USERS=userenv1:pass1 userenv2:pass2" -p 2022:22 \
#         -v "$rootDir/$containerTmpDir/ssh_host_rsa_key:/home/userenv1/.ssh/keys/id_rsa.pub:ro" \
#         -d "$imageName" > "$redirect" 2>&1
#
#     waitForServer "$containerName" "2022"
#     assertTrue "waitForServer" $?
#
#     # TODO: Check with local version
# }

# -v "$testDir/files/sshd_config:/etc/openssh/sshd_config:ro" \

# function testSCP() {
# TODO: Add dependencies if need
# if ! type -p "sshpass" > /dev/null; then
#     echo "SSHPass Required"
#     exit 1
# fi
# }

suite_addTest testRunContainer
suite_addTest testListenSSH
suite_addTest testEnableRoot
suite_addTest testUsersConf
suite_addTest testCommandCreateUsers
suite_addTest testEnvCreateUsers
suite_addTest testSFTPServer
# suite_addTest testRSACertificate
