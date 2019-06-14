#!/bin/bash
program_name="$(basename $0)"
  
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

overwrite=0

while true; do
    case "$1" in
        --help)
            usage
            exit 0
            ;;
        -o | --overwrite)
            overwrite=1
            ;;
        --) shift
            mode="$1"
            shift
            target_files="$@"
            break
            ;;
    esac

    shift
done

for file in "$target_files"; do
    if [ -e "$file" ]; then exists=true; else exists=false; fi

    # if overwrite or file does not exists create
    if [[ "$overwrite" -eq 1 || ! -e "$file" ]]; then
        echo "$overwrite" "$exists"
        echo > "$file"
        chmod "$mode" "$file"
    fi
done

exit "$?"
