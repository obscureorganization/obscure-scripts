#!/usr/bin/env bash
#
# ssh-add-ramdisk.sh
#
# Have you ever wanted to take your SSH keys with you, but did not want to put them on a
# computer that might be stolen or maybe you want to use the keys on someone else's computer,
# but do not want them to be stored permanently there.
#
# SSH is picky about what permissions and ownership the keys have, so typically you will
# not be able to just do an 'ssh-add' directly on the keys on a USB thumb drive.
#
# This allows you to copy your SSH keys from removable media # to a RAM disk, and 
# then adds the SSH keys to your current SSH agent keyring.
#
# This works on both Mac OS X 10.x and on Linux.
#
# Copyright (C) 2019 The Obscure Organization
#
# MIT licensed. See the LICENSE file for details.
#
# This program uses code snippets from Stack Overflow.
# See the inline article links for question and answer author credits.
# Thank you Stack Overflow community for the great questions & answers!
#
# Release History:
#
# 1.0 (2019-11-12)
#  First public release
# 1.1 (2019-12-07)
#  Fixed shellcheck issues, removed redundant code, implemented remove

# Give me BASH or give me death
# http://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on
if [ "$BASH" = "" ]; then
    #shellcheck disable=SC2009
    shell=$(ps | grep \`echo $$\` | grep -v grep |  awk '{ print $4 }')
    echo "$0 is not running in bash (apparently running $shell), aborting."
    echo "Try running 'bash ssh-add-ramdisk'"
    exit 1
fi

# Set unofficial bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DEBUG=${DEBUG:-false}
REMOVE=${REMOVE:-false}

# Thanks https://stackoverflow.com/a/16496491
function usage {
    echo "Usage: $0 [-h] [-v] [-r]"
}

set +u
while getopts ":hlvr" args; do
    case "${args}" in
        h)
            usage
            exit 0
            ;;
        v)
            DEBUG=true
            ;;
        r)
            REMOVE=true
            shift;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x
finish () {
    $DEBUG && set +x
}
trap finish EXIT

$DEBUG && echo "args: verbose $DEBUG remove $REMOVE"

UNAME=$(uname)
case $UNAME in
	Linux)
		RAMDIR=/media/ramdisk-$USER
        SUDO_UMOUNT=sudo
	;;

	Darwin)
		RAMDIR=/Volumes/ramdisk-$USER
        SUDO_UMOUNT=''
	;;
	*)
		echo "Operating system $UNAME not supported."
		exit 2
	;;
esac

# Remove ramdisk if remove parameter is present
"$REMOVE" && $SUDO_UMOUNT umount "$RAMDIR" && echo "Ramdisk removed" && exit 0

# Set this to the location on your removable media where you store your
# SSH keys
KEY_BAK_DIR=$DIR/Backup/.ssh

echo "Creating ramdisk on $RAMDIR"
# Size of RAMDISK in kilobytes
DISKSIZE=8192
case $UNAME in
	Linux)
        if [[ -b "$RAMDIR" ]]; then
            sudo mkdir -p "$RAMDIR"
            sudo mkfs -q /dev/ram1 "$DISKSIZE"
            sudo mount /dev/ram1 "$RAMDIR"
            sudo chown "$USER" "$RAMDIR"
        else
            echo "$RAMDIR ramdisk device is missing or not a block device, exiting."
            exit 3
        fi
	;;
	Darwin)
        # Size in 512 byte sectors
        SECTORS=$((DISKSIZE * 2))
        VOLUME=$(hdiutil attach -nomount "ram://$SECTORS" | sed 's/[^0-9]*$//g')
        $DEBUG && echo "Volume: $VOLUME"
        diskutil erasevolume HFS+ "ramdisk-$USER" "$VOLUME"
	;;
	*)
		echo "Operating system $UNAME not supported."
		exit 2
	;;
esac

# Copy the keys in place
cp -r "$KEY_BAK_DIR" "$RAMDIR"
find "$RAMDIR" -type f -print0 | xargs -0 chmod 600
find "$RAMDIR" -type d -print0 | xargs -0 chmod 700
# Add ALL the keys in the ramdisk to the agent
#shellcheck disable=SC2046
SSH_KEYS=$(grep -I 'PRIVATE KEY' $(find "$RAMDIR" -type f) | cut -f 1 -d: | sort -u)
$DEBUG && printf "SSH Keys:\n%s\n" "$SSH_KEYS"
#shellcheck disable=SC2086
ssh-add $SSH_KEYS
