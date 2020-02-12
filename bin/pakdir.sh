#!/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Package all a directory according to the '.pak' file.                 #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
SCRIPT_NAME="$(basename "$0")"

usage()
{
echo "Usage: $SCRIPT_NAME [options] [TARGET] [ARCHIVE]
     --help              diaplay this help text.
  -p --pak-file=[FILE]   use a specific pak file.
     --include           include specified paths.
     --no-ignore-pak     include the pak file in the resulting archive.
  -g --git               pak a directory according according to a '.gitignore'
                         file.
     --tarball           package as a tarball filtered through gzip instead of
                         a simple compressed archive.
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
    if [ -z "$(git rev-parse --git-dir)" ]; then
        echo_err "Not in a git repository."
        exit 1
    fi

    if [ -n "$tarball" ]; then
        tar --create --verbose --gzip --file "$archive" $(get_git_targets)
    else
        zip "$archive" $(get_git_targets)
    fi
}

pak_dir()
{
	  if [ "$noignore" ]; then
	      if [ -n "$tarball" ]; then
	          tar --create --verbose --gzip --file "$archive" $(get_pak_targets)
        else
            zip "$archive" $(get_pak_targets)
        fi
    else
        if [ -n "$tarball" ]; then
	          tar --create --gzip --verbose --file "$archive" $(get_pak_targets) --exclude "$PWD/$pak_file"
        else
            zip "$archive" $(get_pak_targets) -x "$PWD/$pak_file"
        fi
    fi
}

# parse options and arguments
opts=$(getopt -qo "gp:" --long "help,include,git,pak-file:,no-ignore-pak,tarball" -- "$@")
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
        --no-ignore-pak) noignore=0
            ;;
        --tarball) tarball=0
            ;;
        *) shift
            break
            ;;
    esac
    shift
done

if [ -n "$1" ]; then target_dir="$1"; fi
if [ -n "$2" ]; then archive="$2"; fi
if [ -z "$archive" ]; then archive="$(basename "$(realpath "$target_dir")")"; fi
if [ -n "$tarball" ]; then archive="${archive}.tar.gz"; else archive="$archive.zip"; fi

if [ "$mode" == "git" ]; then
    pak_git
else
    if [ ! -e "$pak_file" ]; then
        echo_err "Could not find pak file '$pak_file'."
        exit 1
    fi
    pak_dir
fi
