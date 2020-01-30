#!/bin/env bash
# # # # # # # # # # # # # # # #
# Reconnect to netctl profile #
# # # # # # # # # # # # # # # #
SCRIPT_NAME="$(basename "$0")"
usage()
{
echo "Uasge: $SCRIPT_NAME [ -p url ] PROFILE
     --help             show this help text.
  -p --ping=PROFILE     specify the netctl profile to restart.
"
}

echo_err()
{
    echo "$SCRIPT_NAME: $1" 1>&2
}

rfunblock() {
    blocks=$(rfkill list wlan --output HARD,SOFT | tail -n 1)

    if [ "${blocks[0]}" == "blocked" ]; then
        echo_err "wlan is blocked at hardware level, cannot connect to wifi"
        exit 1
    fi

    if [ "${blocks[1]}" == "blocked" ]; then
        rfkill unblock wlan
    fi
}

# parse options and arguments
opts=$(getopt -qo "p" --long "help,ping" -- "$@")
eval set -- "${opts}"

ping_target="www.google.com"
while [ "$#" -gt 1 ]; do
    case "$1" in
        --help) usage
            exit 0
            ;;
        -p | --ping) ping_target="$2"
            shift
            ;;
    esac
    shift
done

echo "=== UNBLOCKING WLAN ==="
rfunblock

echo "=== STARTING ${1^^} ==="
sudo netctl restart "$1"

echo "=== PINGING ${ping_target^^} ==="
until ping -c 1 "$ping_target"; do sleep 1; done
