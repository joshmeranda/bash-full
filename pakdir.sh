#!/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Package all a directory according to the '.pak' file.                 #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
SCRIPT_NAME="$(basename "$0")"

usage()
{
#TODO update todo
echo "Usage: $SCRIPT_NAME [options] DIR
     --help                  diaplay this help text.
  -d --dest                  the destination for the created zip file.
  -p --pak-file=[FILE]       use a specific pak file.
     --ignore                ignore specified paths.
     --include               include specified paths.

If no zipfile is specified, the zip created will be nammed after DIR
followed by '_pak.zip'."
}

echo_err()
{
    echo "$SCRIPT_NAME: $1" 1>&2
}

get_pakignore_targets()
{
    if [ -z "$1" ]; then return 0; fi

    local target_contents=("$1"/*)
    local sub_dirs=()

    for ignore in "${ignored_targets[@]}"; do
        target_contents=("${target_contents[@]/$ignore}")
    done

    for target in "${target_contents[@]}"; do
        if [ -d "$target" ]; then
            sub_dirs+=("$target")
            continue
        fi

        target_files+=("$target")
    done

    for dir in "${sub_dirs[@]}"; do
        sub_dirs=("${sub_dirs[@]/$dir}")
        get_pakignore_targets "$dir"
    done
}

get_sub_targets()
{
    dir_contents=("$1"/*)
    for sub_target in "${dir_contents[@]}"; do
        if [ -d "$sub_target" ]; then
            get_sub_targets "$sub_target"
            continue
        fi
        target_files+=("$sub_target")
    done
}

get_pakinclude_targets()
{
    while read -r line; do
        if [ ! -e "$line" ]; then continue; fi

        if [ -f "$line" ]; then target_files+=("$line"); fi

        if [ -d "$line" ]; then get_sub_targets "$line"; fi
    done < "$pak_file"
}

# parse options and arguments
opts=$(getopt -qo "z:" --long "help,zip:,pak-file:,ignore,include" -- "$@")
eval set -- "${opts}"

while :; do
    case "$1" in
        --help) usage
            exit 0
            ;;
        -z | --zip) zip_file="$2"
            shift
            ;;
        --pak-file) pak_file="$2"
            shift
            ;;
        --ignore) mode="ignore"
            mode="ignore"
            ;;
        --include) mode="include"
            mode="include"
            ;;
        --) shift
            target_dir="$1"
            break
            ;;
    esac
    shift
done

# Initialize values
mode="${mode:-ignore}"
target_dir="${target_dir:-.}"
pak_file="$target_dir/${pak_file:-.pak}"
target_files=()
zip_file="${zip_file:-"$(basename "$(pwd)")_pak.zip"}"

# Check for file sanity
if [ ! -d "$target_dir" ]; then echo_err "no such directory '$1'"; exit 1; fi
if [ ! -f "$pak_file" ]; then echo_err "no such file '$pak_file'"; exit 1; fi

# Get targets
if [ "$mode" == "ignore" ]; then
    ignored_targets[0]="$pak_file"

    while read -r line; do
        ignored_targets+=("$target_dir/$line")
    done < "$pak_file"

    get_pakignore_targets "$target_dir"
elif [ "$mode" == "include" ]; then
    get_pakinclude_targets
fi

# create zip file
zip "$zip_file" "${target_files[@]}"

exit "$?"
