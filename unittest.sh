#!/bin/bash

set -e

chmod a+x ./submodules.sh
./submodules.sh

chmod a+x ./tests/run

buildImages() {
    for DIR in debian-stretch-{minimal,standard}; do
        if [ -d "$DIR" ] && [ -f "$DIR/Dockerfile" ]; then
            echo "Start build $DIR"
            export currentOwner="$(id -u -n):$(id -g -n)"
            sudo owner=$currentOwner buildDir="$DIR" imageName="antwal/$DIR:$1" ./tests/run cache logger noclean
        else
            echo "No build $DIR"
        fi
    done
}

# Build all main images
buildImages latest

# Remove dangling images
#docker rmi $(docker images -f "dangling=true" -q)
