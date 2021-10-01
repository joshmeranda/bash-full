#!/usr/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# A minimal in-terminal to-do list and manager                          #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

SCRIPT_NAME="$(basename "$0")"

todo_file="$HOME/.todo"
default_priority=0

function usage {
echo "Usage: $SCRIPT_NAME [list [verbose] | push [PRIORITY:]DESCRIPTION | pop [N] | edit N [PRIORITY:]DESCRIPTION | clear | help]
Very minimal utility for managing a TODO list

  list [verbose]                list all current todo items, can be abbreviated as 'ls'
  push [PRIORITY:]DESCRIPTION   add a new item to the todo list
  pop N                         delete the todo  item with the given number from the todo list
  edit N [PRIORITY:]DESCRIPTION re-prioritize an item
  clear                         remove all items from the list
  help                          show this help text
"
}

function echo_err {
    echo -e "$SCRIPT_NAME: $1" 2>&1
}

function verify_line_no {
    [[ ! "$1" =~ ^[1-9][0-9]?$ ]] && echo_err "invalid item number '$1'" && exit 1
}

function verify_priority {
    [[ ! "$1" =~ ^[1-9][0-9]?$ ]] && echo_err "invalid priority '$1'" && exit 1
}

function list {
  test ! -e "$todo_file" && return 0

  hide_priority=true

  case "$1" in
    "" ) ;;  # do nothing...
    "verbose" ) hide_priority=false
      ;;
    * ) echo_err "unknown list modifier '$1'"
      exit 1
      ;;
  esac

  line_no=1

  while read -r line; do

    if $hide_priority; then
      description=$(echo "$line" | cut -d ':' -f 2)
    else
      description=$(echo "$line" | cut -d ':' -f 1,2)
    fi

    echo -e "$line_no)\t$description"

    ((line_no++))
  done < "$todo_file"
}

function push {
    if [[ ! "$1" =~ .*:.* ]]; then
        description="$1"
    else
        priority="$(echo "$1" | cut --delimiter : --fields 1)"
        description="$(echo "$1" | cut --delimite : --fields 2)"
    fi

    if [ -z "$priority" ] && [ -z "$description" ] || [ -z "$description" ]; then
        echo "expected a description but found none"
        usage
        exit 1
    elif [ -z "$priority" ]; then
        priority=$default_priority
    elif [ -z "$description" ]; then
        description=$priority

        priority=$default_priority
    fi

    verify_priority "$priority"

    test ! -e "$todo_file" && touch "$todo_file"

    echo "$priority:$description" | sort  --reverse --output "$todo_file" - "$todo_file"
}

function pop {
  line_no="$1"

  verify_line_no "$line_no"

  sed -i "${line_no}d" "$todo_file"
}

function clear {
  rm --force "$todo_file"
}

function edit {
    line_no="$1"
    verify_line_no "$line_no"

    if [[ ! "$2" =~ .*:.* ]]; then
        description="$2"
    else
        priority="$(echo "$2" | cut --delimiter : --fields 1)"
        description="$(echo "$2" | cut --delimite : --fields 2)"
    fi

    if [ -z "$priority" ] && [ -z "$description" ] || [ -z "$description" ]; then
        echo "expected a description but found none"
        usage
        exit 1
    elif [ -z "$priority" ]; then
        priority=$default_priority
    elif [ -z "$description" ]; then
        description=$priority

        priority=$default_priority
    fi

    verify_priority "$priority"

    line=$(sed "${line_no}q;d" "$todo_file")

    pop "$line_no"
    push "$description" "$priority"
}

if [ "$#" -eq 0 ]; then
  echo_err "Expected arguments, but received none"
  usage
  exit 1
fi

command="$1"
shift

case "$command" in
  "list" | "ls") list "$@"
    ;;
  "push" ) push "$@"
    ;;
  "pop" ) pop "$@"
    ;;
  "clear" ) clear "$@"
    ;;
  "edit" ) edit "$@"
    ;;
  "help" ) usage
    ;;
  * ) echo_err "unknown command '$command'"
    exit 1
    ;;
esac