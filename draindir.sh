#!/bin/bash

program_name="$(basename $0)"

usage()
{
    echo "Usage: #program_name [OPTIONS] SOURCE... "
    echo "  -d --dest       specify the destination for SOURCE contents. If not"
    echo "                  specified, deaults to './'"
    exit 0
}

opts=$(getopt -o "d:" --long "dest,help": -- "$@")
eval set -- "${opts}"

if [ "$#" -eq 1 ]; then usage; fi

while true; do
    case "$1" in
        --help) usage
                ;;
        -d | --dest)
                dest="$2"
                shift
               ;;
        --) shift
            source="$@"
            break
            ;;
    esac
    shift
done

if [ -z "$dest" ]; then dest="./"; fi

if [ ! -d "$dest" ]; then mkdir "$dest"; fi

for target in "$source"; do
    if [ ! -f "$target" ] && [ ! -d "$target" ]; then
        echo "$program_name: no such file or directory '$target'"
        source="${source[@]/$target}"
    else
        cp_targets="$cp_targets $target/."
    fi
done

cp -a "$cp_targets" "$dest"
rm -r "$source"

exit "$?"