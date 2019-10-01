#!/bin/env bash
# # # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # #
# Use this script to generate directories for testing other scripts, #
# including those which can be found in the bash-full project.       #
# # # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # #

if [ -d "test" ]; then
    rm -r "test"
fi

mkdir "test" "test/sub"
touch "test/"{a..c} "test/sub/"{d..f}
