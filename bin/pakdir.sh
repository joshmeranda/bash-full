#!/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Package all a directory according to the '.pak' file.                 #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
SCRIPT_NAME="$(basename "$0")"

usage()
{
echo "Usage: $SCRIPT_NAME [options] [TARGET] [ZIP]
     --help              diaplay this help text.
  -p --pak-file=[FILE]   use a specific pak file.
     --include           include specified paths.
  -g --git               pak a directory according according to a '.gitignore'
                         file.
"
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

pak_git()
{
    if [ ! -e ".git" ]; then
        echo_err "Not in a git repository."
        exit 1
    fi

    zip "$zip_file" $(get_git_targets) -x "$PWD/.git"
}

pak_dir()
{
    if [ ! -e "$pak_file" ]; then
        echo_err "Could not find pak file '$pak_file'."
        exit 1
    fi

    zip "$zip_file" $(get_pak_targets) -x "$PWD/$pak_file"
}

# parse options and arguments
opts=$(getopt -qo "gp:" --long "help,include,git,pak-file:" -- "$@")
eval set -- "${opts}"

pak_file=".pak"
mode="ignore"
target_dir="$PWD"

while [ "$#" -ne 0 ]; do
    case "$1" in
        --help) usage
            exit 0
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
if [ -n "$2" ]; then zip_file="$2"; fi
if [ -z "$zip_file" ]; then zip_file="$(basename "$(realpath "$target_dir")").zip"; fi

if [ "$mode" == "git" ]; then
    pak_git
else
    pak_dir
fi
