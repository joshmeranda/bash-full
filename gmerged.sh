#!/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Merge and delete a branch all at once. Allows option to delete remote #
# branch as well. g(it) merge d(elete)                                  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
SCRIPT_NAME="$(basename "$0")"

usage() {
echo "Usage: $SCRIPT_NAME [OPTIONS] <branch>
     --help             Display this help text.
  -r --remote-branch    Specify to delete the remote branch on push.
  -l --local-only       Specify to keep all changes local and noot push.
"
}

echo_err() {
    echo -e "$SCRIPT_NAME: $1" 2>&1
}

if [ "$#" -eq 0 ]; then
    echo_err "missing operands.\nTry '$SCRIPT_NAME --help' for help"
    exit 1
fi

opts=$(getopt -o "rl" --long "help,remote-branch,local-only": -- "$@")
eval set -- "${opts}"

remote=0
stayLocal=0

while true; do
    case "$1" in
        --help)
            usage
            exit 0
            ;;
        -r | --remote-branch)
            remote=1
            ;;
        -l | --local-only)
            stayLocal=1
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

echo "=== MERGING ==="
git merge "$branch"

if [ "$stayLocal" -eq 0 ]; then
    echo "=== Pushing ==="
    if [ "$remote" -eq 1 ]; then
        git push --delete origin "$branch"
    else
        git push
    fi
fi

echo "=== DELETING ==="
git branch -D "$branch"
