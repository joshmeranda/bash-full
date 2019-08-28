#!/bin/env bash
program_name="$(basename "$0")"
  
usage()
{
echo "Usage: $program_name [-o] OCTAL-MODE [FILE]..."
echo "  -o --overwrite             specify that existing files should be"
echo "                             overwritten if file of the same name exists"
}

# parse options and arguments
opts=$(getopt -o "o" --long "help,overwrite": -- "$@")
eval set -- "${opts}"

if [ "$#" -eq 1 ]; then
    usage
    exit 0
fi

overwrite=false

while true; do
    case "$1" in
        --help)
            usage
            exit 0
            ;;
        -o | --overwrite)
            overwrite=true
            ;;
        --) shift
            mode="$1"
            shift
            target_files=("$@")
            break
            ;;
    esac

    shift
done

# If no overwrite remove existing files
if [ "$overwrite" = true ]; then
    for file in "${target_files[@]}"; do
        if [ -f "$file" ]; then
            echo "$0: $1 cannot be created, already exists"
            target_files=("${target_files[@]/$file}")
        fi
    done
fi

touch "${target_files[@]}"
chmod "$mode" "${target_files[@]}"

exit "$?"
