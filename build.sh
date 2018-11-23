#!/bin/bash
set -e
set -x

buildbranch() {
        git checkout $1
        for DIR in debian-stretch-{minimal,standard}; do
                cd $DIR
                docker build -t antwal/$DIR:$2 .
                cd ..
        done
}

buildbranch master latest
git checkout master
