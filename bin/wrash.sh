#!/usr/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Provides a simple wrapper around command line utilities which may     #
# benefit from being wrapped in a minimal shell allowing for a more     #
# declarative user experience. (ex git, kubectl, systemctl, etc)        #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

SCRIPT_NAME="$(basename "$0")"

function echo_err {
    echo -e "$SCRIPT_NAME: $1" 2>&1
}

function usage {
    echo "USAGE: $SCRIPT_NAME COMMAND"
}

function handle_args {
    supported_coreutils=('ls' 'dir' 'vdir'
                         'mv' 'rm' 'shred'
                         'mkdir'
                         'chown' 'chgrp' 'chmod' 'touch')

    # check if command should be handled separately (builtins, select coreutils, etc)
    if [ "$1" == 'cd' ]; then
        shift
        cd $*

        return
    elif [ "$1" != 'help' ] && [ "$1" != 'exit' ] \
        && [ "$(type -t "$1")" == "builtin" ] || [[ " ${supported_coreutils[@]} " =~ " ${1} " ]]; then

        bash -c "$*"
        return
    fi

    case "$*" in
        'clear' ) clear ;;

        'exit' ) exit ;;

        'help' ) bash -c "$root_command --help" ;;

        '?' ) echo "Thanks for using Wrash!

To use the commands of the root command simply add the arguments as if you were
calling the command normally (ex. 'commit -m example' instead of
'git commit -m example'). You may also pass any bash shell builtins to run as
if you were in a normal environment, as well as some file management coreutils
(ls, dir, vdir, mv, rm, shred, mkdir, chown, chgrp, chmod, and touch)." ;;

        # pass the arguments to the specified command
        * ) bash -c "$root_command $*" ;;
    esac
}

function prompt {
    echo "[$(whoami) $(pwd)] $root_command > "
}

if [ "$#" -eq 0 ]; then
    echo_err "expected command name but found none"
    usage
    exit
elif [ "$#" -ne 1 ]; then
    echo_err "too many arguments, expected 1"
    usage
    exit
else
    root_command="$1"
fi

if ! which "$root_command" &> /dev/null; then
    echo_err "no such command '$root_command' found on the PATH"
    exit 1
fi

artifi_shell_header="starting wrapper shell: $($root_command --version).
For help using this shell enter '?', or to see the help messaeg of the root command enter 'help'."

echo "$artifi_shell_header"

while read -r -p "$(prompt)" args; do
    [ -n "$args" ] && handle_args ${args[@]}
done
