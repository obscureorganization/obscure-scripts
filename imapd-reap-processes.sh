#!/usr/bin/env bash
#
# imapd-reap-processes.sh
#
# Mail servers sometimes accumulate root-owned imapd processes that
# started and never got killed off for some reason.
# This script purges those, to save process slots and memory.
#
# Create symlinks to activate this:
#
#    sudo ln -s $(pwd)/imapd-reap-processes.sh /usr/local/sbin/imapd-reap-processes.sh
#    sudo ln -s /usr/local/sbin/imapd-reap-processes.sh /etc/cron.daily/imapd-reap-processes
#
# Copyright (C) 2020 The Obscure Organization
#
# MIT licensed. See the LICENSE file for details.
#
# Release History:
#
# 1.0 (January 6, 2020)
#  First public release
#
# 1.1 (May 10, 2020)
#  Shellcheck fix and simplification

# Set unofficial bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x

set +e
PROCESSES=$(pgrep -U 0 imapd)
$DEBUG && echo "$0: processes: $PROCESSES"
set -e
if [[ -n "$PROCESSES" ]]; then
    #shellcheck disable=SC2086
    kill $PROCESSES
fi
