#!/bin/bash

set -Eeo pipefail
# set -e

# shellcheck disable=2154
# trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

kernel=$(uname)
currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
reArgsMaybe="^[^:[:space:]]+:.*$" # Smallest indication of attempt to use argument

optionBuild=false
optionBuildValue=""
optionVerbose=false
optionCleanUp=false
optionTagValue="latest"
optionArgs=false
optionArgsValue=""

function log() {
    LRED='\033[1;31m'
    CYAN='\033[0;36m'
    NC='\033[0m'
    echo -e "${LRED}[$0]${NC} ${CYAN}$*${NC}" >&2
}

function display_usage() {
    echo
    echo "Usage: $0"
    echo
    echo " -h , --help     Display usage instructions"
    echo " -b , --build    Build docker image      (optional, name of folder)"
    echo " -t=, --tag=     Tag of docker image     (required, tag name)"
    echo " -a=, --args=    Docker Build Args       (optional, use sub string value)"
    echo " -v , --verbose  Display build output    ( default, is false)"
    echo " -c , --cleanup  Clear image after build ( default, if false)"
    echo
}

function raise_error() {
    local error_message="$@"
    log "${error_message}" 1>&2;
}

if [ "${kernel}" == "Darwin" ]; then
    log "MacOS System detected"
else
    log "Linux System detected"
fi

# Ask if need password for SUDO
# Asked on MacOS or Linux, not ask on Travis CI
sudo test 1 -eq 1

# On travis or Mac need executable permission
chmod a+x "$currentDir/.travis/install.sh"
chmod a+x "$currentDir/tests/run"

# Check docker
command -v docker >/dev/null 2>&1 || { log >&2 "I require Docker but it's not installed. Aborting."; exit 1; }

# Check shunit2
if [ ! -f "$currentDir/tests/shunit2/shunit2" ]; then
    log "Installing shunit2 ..."
    "$currentDir/.travis/install.sh"
fi

# parse command line arguments
while [[ $# -gt 0 ]]; do
    argument="$1"
    log "arguments: $1"
    case $argument in
        -h|--help)
          display_usage
          exit 0
          ;;
        -b|--build)
          optionBuild=true
          log "build: $2"
          # Build option can be empty/null
          if [[ $2 != *"-" && $2 != *"--" ]]; then
              optionBuildValue="$2"
              shift
          fi
          shift
          ;;
        -t=*|--tag=*)
          # tag value can't be empty
          if [ -z "${argument#*=}" ]; then
              raise_error "Tag option can't be empty"
              display_usage
              exit 1
          fi
          optionTagValue="${argument#*=}"
          shift # past argument=value
          ;;
        -a=*|--args=*)
          optionArgs=true
          if [ -z "${argument#*=}" ]; then
              raise_error "Args option can't be empty"
              display_usage
              exit 1
          fi
          optionArgsValue="${argument#*=}"
          shift # past argument=value
          ;;
        -v|--verbose)
          optionVerbose=true
          shift # past argument
          ;;
        -c|--cleanup)
          optionCleanUp=true
          shift # past argument
          ;;
        *)
          raise_error "Unknown argument: ${argument}"
          display_usage
          exit 1
          ;;
    esac
done

if [[ -z $argument || $optionBuild != true ]]; then
    raise_error "Build argument to be always present."
    display_usage
    exit 1
fi

commands="build"
commands="$commands $($optionVerbose && echo "verbose" || echo "quiet")"
commands="$commands $($optionCleanUp && echo "cleanup" || echo "noclean")"

if [[ -z $optionBuildValue && $optionTagValue == "latest" ]]; then

    for DIR in debian-stretch-{minimal,makepasswd,openssh}; do
        if [ -d "$DIR" ] && [ -f "$DIR/Dockerfile" ]; then
            log "Start build $DIR:$optionTagValue ($commands)"
            export currentOwner=""; currentOwner="$(id -u -n):$(id -g -n)"
            sudo owner="$currentOwner" buildDir="$DIR" imageName="antwal/$DIR:$optionTagValue" "$currentDir"/tests/run $commands
        else
            log "Skipped $DIR, not is a valid docker build folder"
        fi
    done

elif [[ ! -z $optionBuildValue && $optionTagValue == "latest" ]]; then

    if [ -d "$optionBuildValue" ] && [ -f "$optionBuildValue/Dockerfile" ]; then
        log "Start build $optionBuildValue:$optionTagValue ($commands)"
        export currentOwner=""; currentOwner="$(id -u -n):$(id -g -n)"
        sudo owner="$currentOwner" buildDir="$optionBuildValue" imageName="antwal/$optionBuildValue:$optionTagValue" "$currentDir"/tests/run $commands
    else
        log "Skipped $optionBuildValue, not is a valid docker build folder"
        exit 0
    fi

elif [[ -z $optionBuildValue && $optionTagValue != "latest" ]]; then
    raise_error "If tag name not is latest, you need specific build folder"
    display_usage
    exit 1
else
    # optionBuildValue != null and optionTagValue != latest
    if [ $optionArgs != true ]; then
        log "Docker Build Args not is present."
    fi

    commands="$commands '$optionArgsValue'"

    if [ -d "$optionBuildValue" ] && [ -f "$optionBuildValue/Dockerfile" ]; then
        log "Start build $optionBuildValue:$optionTagValue ($commands)"
        export currentOwner=""; currentOwner="$(id -u -n):$(id -g -n)"
        sudo owner="$currentOwner" buildDir="$optionBuildValue" imageName="antwal/$optionBuildValue:$optionTagValue" "$currentDir"/tests/run $commands
    else
        log "Skipped $optionBuildValue, not is a valid docker build folder"
        exit 0
    fi

fi

if [ $optionBuild ]; then
    # Remove dangling images
    if [ "$(docker images -f "dangling=true" -q)" != "" ]; then
        log "Cleanup dangling images..."
        docker rmi "$(docker images -f "dangling=true" -q)"
    fi
fi
