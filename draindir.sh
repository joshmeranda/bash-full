#!/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Drain the contents of a directory into the current directory, or one  #
# specified.                                                            #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

SCRIPT_NAME="$(basename "$0")"

usage() {
echo "Usage: $SCRIPT_NAME [OPTIONS] SOURCE...
     --help       Display this help text
  -d --dest       Specify the destination for SOURCE contents. If not
                  specified, defaults to './'.
"
}

echo_err() {
    echo -e "$SCRIPT_NAME: $1" 2>&1
}

if [ "$#" -eq 0 ]; then
    echo_err "missing operands.\nTry '$SCRIPT_NAME --help' for help"
    exit 1;
fi

# Parse arguments.
while true; do
    case "$1" in
        --help)
            usage
            ;;
        -d | --dest)
            dest="$2"
            shift
           ;;
        *)
            source=("$@")
            echo "=== 000 ==="
            echo "${source[@]}"
            break
            ;;
    esac

    shift
done

# Ensure that the proper destination direcory exists and is not a regular file
if [ -z "$dest" ]; then
    dest="./"
elif [ -f "$dest" ]; then
    echo_err "Cannot drain directory into a file."
    exit 1
elif [ ! -d "$dest" ]; then
    mkdir "$dest"
fi

# Drain all source directories into the target.
for target in "${source[@]}"; do
    echo "$target"/*

    if mv "$target"/* "$dest"; then
        rm -r "$target"
    fi
done

exit "$?"
