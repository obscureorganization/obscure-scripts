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
#  Fixed shellcheck issues, removed redundant code

# Give me BASH or give me death
# http://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on
if [ "$BASH" = "" ]; then
    #shellcheck disable=SC2009
    shell=$(ps | grep \`echo $$\` | grep -v grep |  awk '{ print $4 }')
    echo "$0 is not running in bash (apparently running $shell), aborting."
    echo "Try running 'bash ssh-add-ramdisk'"
    exit 1
fi

# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/16496491
function usage {
    echo "Usage: $0 [-h] [-v] [-r]"
}

set +u
while getopts ":hlvr" args; do
    case "${args}" in
        h)
            usage
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

case $UNAME in
	Linux)
		RAMDIR=/media/ramdisk-$USER
	;;

	Darwin)
		RAMDIR=/Volumes/ramdisk-$USER
	;;
	*)
		echo "Operating system $UNAME not supported."
		exit 2
	;;
esac

# Remove ramdisk if remove parameter is present
"$REMOVE" && sudo umount "$RAMDIR" && echo "Ramdisk removed" && exit 0

# Set this to the location on your removable media where you store your
# SSH keys
KEY_BAK_DIR=$DIR/Backup/.ssh
UNAME=$(uname)

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
        SECTORS=$((DISKSIZE * 2)) # Size in 512 byte sectors
        diskutil erasevolume HFS+ "ramdisk-$USER" "$(hdiutil attach -nomount "ram://$SECTORS")"
	;;
	*)
		echo "Operating system $UNAME not supported."
		exit 2
	;;
esac

# Copy the keys in place
cp -r "$KEY_BAK_DIR" "$RAMDIR"
chmod 700 "$RAMDIR/.ssh"
chmod 600 "$RAMDIR/.ssh/*"
# Add ALL the keys in the ramdisk to the agent
#shellcheck disable=SC2046
ssh-add $(grep 'PRIVATE KEY' "RAMDIR/.ssh/id*" | cut -f 1 -d: | sort -u)
