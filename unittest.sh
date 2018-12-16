#!/bin/bash

set -e

chmod a+x ./submodules.sh
./submodules.sh

chmod a+x ./tests/run.sh
./tests/run.sh

