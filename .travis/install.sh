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
        if find "$path" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
            echo "Removed old content of $path"
            rm -Rf $path
        else
            echo "Install $url to $path."
            git submodule add -f "$url" "$path"
        fi
    done
