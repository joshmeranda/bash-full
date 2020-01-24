#!/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Merge and delete a branch all at once. Allows option to delete remote #
# branch as well. g(it) merge d(elete)                                  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
SCRIPT_NAME="$(basename "$0")"

usage() {
echo "Usage: $SCRIPT_NAME [OPTIONS] BRANCH
     --help      display this help text.
  -r --remove    delete the remote branch on push.
  -p --push      push to remote after merge.
"
}

echo_err() {
    echo -e "$SCRIPT_NAME: $1" 2>&1
}

if [ "$#" -eq 0 ]; then
    echo_err "missing operands.\nTry '$SCRIPT_NAME --help' for help"
    exit 1
fi

opts=$(getopt -o "rp" --long "help,remove,push": -- "$@")
eval set -- "${opts}"

remove=0
push=0

while true; do
    case "$1" in
        --help)
            usage
            exit 0
            ;;
        -r | --remove)
            remove=1
            ;;
        -p | --push)
            push=1
            ;;
        --) shift
            branch="$1"
            break
    esac
    shift
done

if [ -z "$branch" ]; then
    echo_err "no branch specified"
    exit 1
fi

# exit on command error
set -e

echo "=== MERGING ==="
git merge "$branch"

if [ "$push" -eq 1 ]; then
    echo "=== Pushing ==="
    if [ "$remove" -eq 1 ]; then
        git push --delete origin "$branch"
    else
        git push
    fi
fi

echo "=== DELETING ==="
git branch -D "$branch"
