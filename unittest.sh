#!/bin/bash

set -e

# TODO: Need add push image to docker
# TODO: Fix args for travis / local / debug build

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

chmod a+x ./submodules.sh
chmod a+x ./tests/run

if [ ! -f "$currentDir/tests/shunit2/shunit2" ]; then
    ./submodules.sh
fi

buildImages() {
    for DIR in debian-stretch-{minimal,makepasswd,openssh}; do
        if [ -d "$DIR" ] && [ -f "$DIR/Dockerfile" ]; then
            echo "Start build $DIR:$1"
            export currentOwner="$(id -u -n):$(id -g -n)"
            sudo owner=$currentOwner buildDir="$DIR" imageName="antwal/$DIR:$1" ./tests/run
        else
            echo "Skip build $DIR:$1"
        fi
    done
}

# Build all main images
buildImages latest

# Remove dangling images
if [ "$(docker images -f "dangling=true" -q)" != "" ]; then
    echo "Clean up dangling images..."
    docker rmi $(docker images -f "dangling=true" -q)
fi
