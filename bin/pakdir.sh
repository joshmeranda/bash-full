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
  -g --git                   pak a directory according according to a '.gitignore' file.
  -z --zip=[FILE]            the name of the resulting zip file.

If no zipfile is specified, the zip created will be nammed after DIR
followed by '_pak.zip'."
}

echo_err()
{
    echo "$SCRIPT_NAME: $1" 1>&2
}

# Zip contents of the current git branch
get_git_targets()
{
    git ls-tree -r --name-only "$(git branch | grep \* | cut --delimiter ' ' --fields 2)" | tr '\n' ' '
}

# Find all files pointed to by the pak file
get_pak_targets()
{
    pattern=""
    while IFS= read -r path; do
        if [ -d "$path" ]; then
            pattern="$pattern|.*/$path(/.*)?"
        elif [ -f "$path" ]; then
            pattern="$pattern|.*/$path"
        fi
    done < "$pak_file"

    # remove the first uneeded pipe
    pattern="${pattern:1}"

    if [ "$mode" == "ignore" ]; then
        find "$target_dir" -regextype posix-egrep -not -regex "$pattern" | tr '\n' ' '
    elif [ "$mode" == "include" ]; then
        find "$target_dir" -regextype posix-egrep -regex "$pattern" | tr '\n' ' '
    fi
}

# parse options and arguments
opts=$(getopt -qo "z:g" --long "help,zip:,pak-file:,ignore,include,git" -- "$@")
eval set -- "${opts}"

pak_file=".pak"
mode="ignore"
target_dir="$PWD"

while [ "$#" -ne 0 ]; do
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
        --include) mode="include"
            ;;
        -g | --git) mode="git"
            ;;
        *) shift
            break
            ;;
    esac
    shift
done

if [ -n "$1" ]; then target_dir="$1"; fi

if [ -z "$zip_file" ]; then zip_file="$(basename "$(realpath "$target_dir")").zip"; fi

if [ "$mode" == "git" ]; then
    zip "$zip_file" $(get_git_targets) -x "$PWD/.git"
else
    zip "$zip_file" $(get_pak_targets) -x "$PWD/$pak_file"
fi
