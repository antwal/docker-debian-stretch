#!/bin/bash

set -e

chmod a+x ./submodules.sh
./submodules.sh

chmod a+x ./tests/run

buildImages() {
    for DIR in debian-stretch-{minimal,standard}; do
        # TODO: Check if folder exist and contain Dockefile
        export currentOwner="$(id -u -n):$(id -g -n)"
        sudo owner=$currentOwner buildDir="$DIR" imageName="antwal/$DIR:$1" ./tests/run cache logger noclean
    done
}

# Build all main images
buildImages latest

# Remove dangling images
docker rmi $(docker images -f "dangling=true" -q)
