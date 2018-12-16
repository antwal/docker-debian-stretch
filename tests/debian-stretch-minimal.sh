#!/bin/bash

##############################################################################
## Tests
##############################################################################

function testCommandPassthrough() {
    echo "testCommandPassthrough $imageName -> $containerName"
}

suite_addTest testCommandPassthrough
