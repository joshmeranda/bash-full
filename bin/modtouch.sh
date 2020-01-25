#!/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # #
# Create a file with specified permissions. #
# # # # # # # # # # # # # # # # # # # # # # #
SCRIPT_NAME="$(basename "$0")"
  
usage()
{
echo "Usage: $SCRIPT_NAME [-o] OCTAL-MODE FILE [FILE ...]
  -o --overwrite    specify that existing files should be overwritten if file
                    of the same name exists
"
}

# parse options and arguments
opts=$(getopt -o "oe" --long "help,overwrite,edit": -- "$@")
eval set -- "${opts}"

if [ "$#" -eq 1 ]; then
    usage
    exit 1
fi

while :; do
    case "$1" in
        --help) usage
            exit 0
            ;;
        -o | --overwrite) overwrite=1
            ;;
        -e | --edit) edit=1
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
if [ "$overwrite" ]; then
    for file in "${target_files[@]}"; do
        if [ -f "$file" ]; then
            echo "$0: $1 cannot be created, already exists"
            target_files=("${target_files[@]/$file}")
        fi
    done
fi

touch "${target_files[@]}"
chmod "$mode" "${target_files[@]}"

if [ "$edit" ]; then nano "${target_files[@]}"; fi

exit "$?"
