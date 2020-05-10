#!/usr/bin/env bash
#
# imapd-reap-processes.sh
#
# Mail servers sometimes accumulate imapd processes that
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

# Set unofficial bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x

set +e
PROCESSES=$(ps auxfw \
    | grep ^root.*imapd \
    | grep -v grep \
    | grep -v \\_ \
    | sed 's/  */ /g' \
    | cut -f 2 -d' ')
$DEBUG && echo "$0: processes: $PROCESSES"
set -e
if [[ -n "$PROCESSES" ]]; then
    kill $PROCESSES
fi
