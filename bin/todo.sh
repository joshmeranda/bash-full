#!/usr/bin/env bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# A minimal in-termal to-do list and manager                            #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

SCRIPT_NAME="$(basename "$0")"

todo_file="$HOME/.todo"
default_priority=9

usage() {
echo "Usage: $SCRIPT_NAME [list [verbose] | add DESCRIPTION [PRIORITY] | remove NUMBER | clear | help]
Very minimal utility for managing a TODO list

  list [verbose]  list all current todo items
  add DESCRIPTION [PRIORITY]  add a new item to the todo list
  remove NUMBER   delete the todo item with the given number from the todo list
  clear           remove all items from the list
  edit NUMBER PRIORITY re-prioritize an item
  help            show this help text
"
}

echo_err() {
    echo -e "$SCRIPT_NAME: $1" 2>&1
}

verify_line_no() {
    echo "$1" | grep --quiet --extended-regexp "^[^0-9]$" && echo_err "invalid item number $1" && exit 1
}

verify_priority() {
  echo "$priority" | grep --quiet --invert-match --extended-regexp "^[0-9][0-9]?$" && echo_err "invalid priority $priority" && exit 1
}

list() {
  test ! -e "$todo_file" && return 0

  hide_priority=true

  case "$1" in
    "" ) ;;  # do nothing...
    "verbose" ) hide_priority=false
      ;;
    * ) echo_err "unknown list modifier $1"
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

add() {
  description="$1"

  if [ -n "$2" ]; then
    priority=$2
    verify_priority "$priority"
  else
    priority=$default_priority
  fi

  test ! -e "$todo_file" && touch "$todo_file"

  echo "$priority:$description" | sort -o "$todo_file" - "$todo_file"
}

remove() {
  line_no="$1"

  verify_line_no "$line_no"

  sed -i "${line_no}d" "$todo_file"
}

clear() {
  rm --force "$todo_file"
}

edit() {
  line_no="$1"
  priority="$2"

  verify_line_no "$line_no"
  verify_priority "$priority"

  line=$(sed "${line_no}q;d" "$todo_file")
  description=$(echo "$line" | cut -d ':' -f 2)

  remove "$line_no"
  add "$description" "$priority"
}

if [ "$#" -eq 0 ]; then
  echo_err "Expected arguments, but received none"
  usage
  exit 1
fi

command="$1"
shift

case "$command" in
  "list" ) list "$@"
    ;;
  "add" ) add "$@"
    ;;
  "remove" ) remove "$@"
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