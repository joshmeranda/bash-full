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
    if [ -z "$1" ]; then return 0; fi

    local target_contents=("$1"/*)
    local sub_dirs=()

    for ignore in "${ignored_targets[@]}"; do
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
        get_ignore_targets "$dir"
    done
}

get_sub_targets()
{
    dir_contents=("$1"/*)
    for sub_target in "${dir_contents[@]}"; do
        if [ -d "$sub_target" ]; then
            get_sub_targets "$sub_target"
            continue
        fi
        target_files+=("$sub_target")
    done
}

get_include_targets()
{
    while read -r line; do
        if [ ! -e "$line" ]; then continue; fi

        if [ -f "$line" ]; then target_files+=("$line"); fi

        if [ -d "$line" ]; then get_sub_targets "$line"; fi
    done < "$pak_file"
}

# parse options and arguments
opts=$(getopt -qo "d:" --long "help,dest:,pak-file:,ignore,include" -- "$@")
eval set -- "${opts}"

while :; do
    case "$1" in
        --help) usage
            ;;
        -d | --dest) dest="$2"
            shift
            ;;
        --pak-file) pak_file="$2"
            shift
            ;;
        --ignore) mode="ignore"
            pak_file=".pakignore"
            ;;
        --include) mode="include"
            pak_file=".pakinclude"
            ;;
        --) shift
            target_dir="$1"
            break
            ;;
    esac
    shift
done

# # # # # # # # # # #
# Initialize values #
# # # # # # # # # # #
mode="${mode:-ignore}"
target_dir="${target_dir:-.}"
pak_file="$target_dir/${pak_file:-.pakignore}"
dest="${dest:-.}"
if [ "$target_dir" == "." ]; then
    zip_file="$dest/$(basename $(pwd))_pak.zip";
else
    zip_file="$dest/${target_dir}_pak.zip"
fi

# # # # # # # # # # # # #
# Check for file sanity #
# # # # # # # # # # # # #
if [ ! -d "$target_dir" ]; then echo_err "no such directory '$1'" 1; fi
if [ ! -f "$pak_file" ]; then echo_err "no such file '$pak_file'" 1; fi

target_files=()

# # # # # # # #
# Get targets #
# # # # # # # #
if [ "$mode" == "ignore" ]; then
    ignored_targets=()
    while read -r line; do ignored_targets+=("$target_dir/$line"); done <"$pak_file"
    get_ignore_targets "$target_dir"
elif [ "$mode" == "include" ]; then
    get_include_targets
fi

# # # # # # # #
# Zip targets #
# # # # # # # #
zip -q "$zip_file" "${target_files[@]}"

exit "$?"