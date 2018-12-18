#!/bin/bash

set -e

# TODO: Need add push image to docker

chmod a+x ./submodules.sh
./submodules.sh

chmod a+x ./tests/run

buildImages() {
    for DIR in debian-stretch-*; do
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
