#!/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Merge and delete a branch all at once. Allows option to delete remote #
# branch as well. g(it) merge d(elete)                                  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
SCRIPT_NAME="$(basename "$0")"

usage() {
echo "Usage: $SCRIPT_NAME [OPTIONS] BRANCH
     --help      display this help text.
  -d --delete    delete the remote branch on push.
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

opts=$(getopt -o "dp" --long "help,delete,push": -- "$@")
eval set -- "${opts}"

delete=0

while true; do
    case "$1" in
        --help)
            usage
            exit 0
            ;;
        -d | --delete)
            delete=1
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

echo -e "=== MERGING ==="
git merge "$branch"

if [ -n "$push" ]; then
    echo -e "\n=== PUSHING ==="
    git push
fi

if [ "$delete" -eq 1 ]; then
    echo -e "\n=== DELTEING LOCAL ==="
    git branch --delete "$branch"

    if [ -n "$push" ] && [ -n "$(git ls-remote $(git config --get remote.origin.url) history)" ]; then
        echo -e "\n=== DELETEING REMOTE ==="
        git push --delete origin "$branch"
    fi
fi