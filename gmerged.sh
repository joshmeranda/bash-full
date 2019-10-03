#!/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Merge and delete a branch all at once. Allows option to delete remote #
# branch as well. g(it) merge d(elete)                                                       #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
SCRIPT_NAME="$(basename "$0")"

usage() {
echo "Usage: $SCRIPT_NAME [OPTIONS] branch name"
}

echo_err() {
    echo -e "$SCRIPT_NAME: $1" 2>&1
}

if [ "$#" -eq 0 ]; then
    echo_err "missing operands.\nTry '$SCRIPT_NAME --help' for help"
    exit 1
fi

opts=$(getopt -o "r" --long "help,remote": -- "$@")
eval set -- "${opts}"

remote=0

while true; do
    case "$1" in
        --help)
            usage
            exit 0
            ;;
        -r | --remote)
            remote=1
            ;;
        --) shift
            branch="$1"
            break
    esac
done

if [ -z "$branch" ]; then
    echo_err "no branch specified"
    exit 1
fi

echo "=== MERGING ==="
git merge "$branch"

echo "=== Pushing ==="
if [ "$remote" -eq 1 ]; then
    git push --delete origin "$branch"
else
    git push
fi

echo "=== DELETING ==="
git branch -D "$branch"
