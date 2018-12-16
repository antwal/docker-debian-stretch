#!/bin/bash
# See: https://github.com/kward/shunit2

if [ $UID != 0 ] && ! groups | grep -qw docker; then
    echo "Run with sudo/root or add user $USER to group 'docker'"
    exit 1
fi

argBuild=${1:-"build"}
argOutput=${2:-"quiet"}
argCleanup=${3:-"cleanup"}
testDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
buildDir="$testDir/.."
buildOptions=(--tag "$imageName")

imageName="atmoz/sftp_test"

if [ "$argOutput" == "quiet" ]; then
    redirect="/dev/null"
else
    redirect="/dev/stdout"
fi

if [ ! -f "$testDir/shunit2/shunit2" ]; then
    echo "Could not find shunit2 in $testDir/shunit2."
    echo "Run 'git submodules init && git submodules update'"
    exit 2
fi

# clear argument list (or shunit2 will try to use them)
set --

##############################################################################
## Helper functions
##############################################################################

function setUp() {
    # shellcheck disable=SC2154
    containerName="atmoz_sftp_${_shunit_test_}"
    containerTmpDir="$(mktemp -d "/tmp/${containerName}_XXXX")"
    export containerName containerTmpDir

    retireContainer "$containerName" # clean up leftover container
}

##############################################################################
## Tests
##############################################################################



##############################################################################
## Run
##############################################################################

# shellcheck disable=SC1090
source "$testDir/shunit2/shunit2"
# Nothing happens after this
