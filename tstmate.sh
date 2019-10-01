#!/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Watch for changes in a a project and run a specifieid test script #
# when contents change.                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

SCRIPT_NAME="$(basename "$0")"

usage() {
echo "Usage: $SCRIPT_NAME --project PATH --script SCRIPT
  -p --project    The path to the tagre project.
  -s --script     The testing script to run on file change.
"
}

echo_err() {
    echo -e "$SCRIPT_NAME: $1" 2>&1
}

if [ "$#" -eq 0 ]; then
    echo_err "missing operands.\nTry '$SCRIPT_NAME --help' for help"
    exit 1
fi

# Parse arguments.
while [ "$#" -gt 0 ]; do
    case "$1" in
        --help)
            usage
            exit 0
            ;;
        -t | --test-script)
            script="$2"
            ;;
        -p | --project)
            project="$2"
            ;;
    esac

    shift
done

# Ensure both a project and testing scritpt were specified.
if [ -z "$project" ]; then echo_err "no project path specified"; exit 1; fi
if [ -z "$script" ]; then echo_err "no test script specified"; exit 1; fi

# TODO Parse .gitignore for what to ignore
while true; do
    # Find all project files to watch for changes
    find "$project" -type f -not \( \
            -path '*/\.git/*'       \
            -o -path '*/\.svn/*'    \
            -o -path "*/*\.iml"     \
            -o -path '*/\.idea/*'   \
            -o -path '*/target/*'   \
        \)                          \
        -exec inotifywait --event modify {} +

        # Run testing script after MODIFY event is detected
        if [ -f "$script" ]; then
            evel < "$script"
        else
            eval "$script"
        fi

        break
done

exit "$?"