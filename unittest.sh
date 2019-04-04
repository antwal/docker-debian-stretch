#!/bin/bash

set -Eeo pipefail
# set -e

# shellcheck disable=2154
# trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

kernel=$(uname)
currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
reArgsMaybe="^[^:[:space:]]+:.*$" # Smallest indication of attempt to use argument

function log() {
    LRED='\033[1;31m'
    CYAN='\033[0;36m'
    NC='\033[0m'
    echo -e "${LRED}[$0]${NC} ${CYAN}$*${NC}" >&2
}

if [ "${kernel}" == "Darwin" ]; then
    log "MacOS System detected"
else
    log "Linux System detected"
fi

# Ask if need password for SUDO
sudo test 1 -eq 1

# chmod a+x "$currentDir/submodules.sh"
chmod a+x "$currentDir/.travis/install.sh"
chmod a+x "$currentDir/tests/run"

if [ ! -f "$currentDir/tests/shunit2/shunit2" ]; then
    # "$currentDir/submodules.sh"
    log "Need install shunit2 ..."
    "$currentDir/.travis/install.sh"
fi

buildImages() {
    for DIR in debian-stretch-{minimal,makepasswd,openssh}; do
        if [ -d "$DIR" ] && [ -f "$DIR/Dockerfile" ]; then
            log "Start build $DIR:$1 ($2)"
            export currentOwner=""; currentOwner="$(id -u -n):$(id -g -n)"
            sudo owner="$currentOwner" buildDir="$DIR" imageName="antwal/$DIR:$1" "$currentDir"/tests/run $2
        else
            log "Skip build $DIR:$1"
        fi
    done
}

buildPython() {
    log "Start build python version image ..."
    # docker build -t antwal/debian-stretch-python:3.5.6 --build-arg version="3.5.6" debian-stretch-python/
    # docker build -t antwal/debian-stretch-python:3.6.8 --build-arg version="3.6.8" debian-stretch-python/
    # docker build -t antwal/debian-stretch-python:3.7.2 --build-arg version="3.7.2" debian-stretch-python/
}

if [[ -z "$1" || "$1" =~ $reArgsMaybe ]]; then
    # Build all main images
    buildImages latest
else
    for cmd in "$@"; do
        commands="$commands$cmd "
    done
    buildImages latest "$commands"
fi

# Remove dangling images
if [ "$(docker images -f "dangling=true" -q)" != "" ]; then
    log "Clean up dangling images..."
    docker rmi "$(docker images -f "dangling=true" -q)"
fi
