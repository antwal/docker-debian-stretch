#!/bin/bash

# Set an option to exit immediately if any error appears
set -o errexit

currentDir="$( pwd )"

echo "Installing dependencies from git modules ..."

git config -f "$currentDir/.gitmodules" --get-regexp '^submodule\..*\.path$' |
    while read path_key path
    do
        url_key=$(echo "$path_key" | sed 's/\.path/.url/')
        url=$(git config -f .gitmodules --get "$url_key")
        if [[ ! -d "$currentDir/$path" || ! -f "$currentDir/tests/shunit2/shunit2" ]]; then
            git submodule add -f "$url" "$path"
        else
            echo "$path -> $url, already installed."
        fi
    done
