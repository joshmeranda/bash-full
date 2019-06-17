#!/bin/bash
program_name="$(basename $0)"

usage()
{
echo "Usage: $program_name [options] SOURCE [zip_file]"
echo "     --help                  diaplay this help text."
echo "  -d --dest                  the destination for the created zip file."
echo "     --ignore-file=[FILE]    use a specific pakignore file."
echo
echo "  If no zipfile is specified, the zip created will be nammed after SOURCE"
echo "  followed by '_pak.zip'."
exit 0
}

echo_err()
{
    echo "$program_name: $1" 1>&2

    if [ -z "$2" ]; then exit 1; else exit "$2"; fi
}

get_ignore_targets()
{
    local ignore_count=1

    if [ ! -f "$pakignore" ]; then echo_err "No pakignore file found"; fi

    while read -r line; do
        ignore_targets+=("$target_dir/$line")
    done < "$pakignore"
}

get_target_files()
{
    if [ -z "$1" ]; then return 0; fi

    local target_contents=("$1"/*)
    local sub_dirs=()

    for ignore in "${ignore_targets[@]}"; do
        target_contents=("${target_contents[@]/$ignore}")
    done

    for target in "${target_contents[@]}"; do
        if [ -d "$target" ]; then
            sub_dirs+=("$target")
            continue
        fi

        target_files+=("$target")
    done

    for dir in "$sub_dirs"; do
        sub_dirs=("${sub_dirs[@]/$dir}")
        get_target_files "$dir"
    done
}

# parse options and arguments
opts=$(getopt -qo "d:" --long "help,dest,ignore-file": -- "$@")
eval set -- "${opts}"

while :; do
    case "$1" in
        --help) usage
            ;;
        -d | --dest) dest="$2"
            shift
            ;;
        --ignore-file) pakignore="$2"
            shift
            ;;
        --) shift
            target_dir="$1"
            break
            ;;
    esac
    shift
done

if [ -z "$target_dir" ]; then target_dir="."; fi
if [ -z "$pakignore" ]; then pakignore="${target_dir}/.pakignore"; fi
if [ ! -d "$target_dir" ]; then echo_err "no such directory '$1'" 1; fi
if [ -z "$dest" ]; then dest="."; fi
if [ "$target_dir" == "." ]; then zip_file="$dest/$(basename $(pwd))_pak.zip";
else zip_file="$dest/${target_dir}_pak.zip"; fi

target_files=()
ignore_targets=()
get_ignore_targets
get_target_files "$target_dir"

zip -q "$zip_file" "${target_files[@]}"