#!/usr/bin/env bash
# # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Merge the content of one or more gitignore files from the upstream standard  #
# gitignore repository: github.com/github/gitignore                            #
# # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # # # # #

SCRIPT_NAME="$(basename "$0")"
upstream_url='https://github.com/github/gitignore'

# the directory where the gitignore repository to use was cloned
gitignore_dir="$HOME/.local/share"

# the directory of the cloned repo
gitignore_repo="$gitignore_dir/gitignore"

usage() {
echo "Usage: $SCRIPT_NAME [list | target...]

  target    a list of target gitignores to be included (case insensitive)
  list      request a list off supported gitignores
  update    pull any changes made to the upstream repo into the local clone
  help      show this help text

For a complete list of all available targets please view the upstream repository here:
    $upstream_url"
}

echo_err() {
    echo -e "$SCRIPT_NAME: $1" 2>&1
}

if [ "$#" -eq 0 ]; then
    echo_err "missing operands."
    usage
    exit 1
elif [ "$1" == "help" ]; then
    usage
    exit
fi

# check for templates, and install from upstream if not found
if [ ! -d $gitignore_dir ]; then
    echo_err "could not find templates: no such directory '$gitignore_dir'.
Attempting to clone from $upstream_url..."

    cd $(dirname $gitignore_dir)
    if ! git clone $upstream_url;then
        echo_err "Could not install templates"
        exit 1
    fi
fi

case "$1" in
    "target" )
        shift
        ;;
    "list" )
        find "$gitignore_repo" -name '*.gitignore' -exec basename --suffix .gitignore --multiple '{}' +
        exit
        ;;
    "update" )
        cd "$gitignore_repo"
        git pull
        exit
        ;;
    "help" )
        usage
        exit
        ;;
    * )
        echo_err 'unkown ignore command'
        exit 2
        ;;
esac

# generate find predicates
pattern=()
for name in "$@"; do
    predicates+=(-iname $name.gitignore -o)
done

predicates+=(-false) # necessary for trailinty '-o'

# write gitignore file
gitignore="$(realpath .)/.gitignore"

echo "# # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# This gitignore was auto-generated using the standard templates published by  #
# github here: github.com/github/gitignore                                     #
# # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # # # # #

" > $gitignore

for target in $(find $gitignore_repo ${predicates[@]}); do
    echo "## $(basename $target)" >> $gitignore
    cat $target >> $gitignore
    echo >> $gitignore  # add some whitespace
done
