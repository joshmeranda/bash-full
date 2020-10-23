#!/usr/bin/env bash
# # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Merger the content of one or more gitignore files from the upstream standard #
# gitignore repository: github.com/github/gitignore                            #
# # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # # # # #

SCRIPT_NAME="$(basename "$0")"

usage() {
echo "Usage: $SCRIPT_NAME [targets]

For a complete list of all available targets please view the upstream repository here:
    https://github.com/github/gitignore"
}

echo_err() {
    echo -e "$SCRIPT_NAME: $1" 2>&1
}

if [ "$#" -eq 0 ]; then
    echo_err "missing operands."
    usage
    exit 1
fi

gitignore="$(realpath .)/.gitignore"
url_root='https://raw.githubusercontent.com/github/gitignore/master'
github_root='https://github.com/github/gitignore/blob/master'

# wget each target gigitnore with the url_root prepended
wget_targets=()

for target in "$@"; do
    wget_targets+=("$url_root/$target.gitignore")
done

wget "${wget_targets[@]}"

# merge all gitignores into a single file
for target in "$@"; do
    # begin each gitignore section with the github url
    echo "# $github_root/$target.gitignore" >> $gitignore
    
    cat "$target.gitignore" >> $gitignore
    echo >> $gitignore

    rm --force "$target.gitignore"
done
