#!/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Watch for changes in a a project and run a specifieid test script #
# when contents change.                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

SCRIPT_NAME="$(basename "$0")"

usage() {
echo "Usage: $SCRIPT_NAME --project PATH --script SCRIPT
I am the usage text.
I am another line.
"
}

echo_err() {
    echo -e "$SCRIPT_NAME: $1" 2>&1
}

if [ "$#" -eq 0 ]; then echo_err "missing operands.\nTry '$SCRIPT_NAME --help' for help"; fi

# Parse arguments.
while true; do
    case "$1" in
        --help)
            usage
            exit 0
            ;;
        -s | --script)
            script="$2"
            ;;
        -p | --project)
            project="$2"
            ;;
    esac

    shift
done

# Ensure both a project and testing scritpt were specified.
if [ -z "$project" ]; then echo_err "no project path specified"; fi
if [ -z "$script" ]; then echo_err "no test script specified"; fi

while true; do
    watch --chgexit --no-title \\
        cat "$project"/*

        if ! eval "$script"; then break; fi
done

return "$?"