#!/bin/env bash

program_name="$(basename "$0")"

usage()
{
    echo "Usage: #program_name [OPTIONS] SOURCE... "
    echo "     --help       Display this help text"
    echo "  -d --dest       Specify the destination for SOURCE contents. If not"
    echo "                  specified, deaults to './'"
    exit 0
}

opts=$(getopt -o "d:" --long "dest,help": -- "$@")
eval set -- "${opts}"

if [ "$#" -eq 1 ]; then usage; fi

while true; do
    case "$1" in
        --help) usage
                ;;
        -d | --dest)
                dest="$2"
                shift
               ;;
        --) shift
            source=("$@")
            break
            ;;
    esac
    shift
done

# Ensure that a destination is specified
if [ -z "$dest" ];
    then dest="./"
else
    mkdir "$dest"
fi

drain_targets=()
for target in "${source[@]}"; do
    for file in "$target"/*; do
        drain_targets=("${drain_targets[@]}" "$file")
    done
done

mv "${drain_targets[@]}" "$dest"

exit "$?"
