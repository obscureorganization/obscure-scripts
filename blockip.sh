#!/usr/bin/env bash
#
# blockip.sh
#
# Temporarily block IP addresses via iptables
#
# USAGE
#
#     ./blockip.sh 192.2.0.0
#     ./blockip.sh 192.2.0.1 now+1day
#
# Symlink this into /usr/local/sbin
#
# To run with debugging information enabled:
#
#     DEBUG=true /usr/local/sbin/blockip.sh
#
# LEGAL
# 
# Adapted from user49740's SuperUser answer https://superuser.com/a/933438
#
# Copyright (C) 2020 by The Obscure Organization
#
# MIT licensed. See the LICENSE file for details.
#
# Release History:
#
# 1.0 (May 10, 2020)
#  First public release

# Set unofficial bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x

# Thanks https://askubuntu.com/a/15856
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

# Thanks https://superuser.com/a/933438
HOST=${1:?You must specify an IP address to block.}
SCHEDULE=${2:-now+1hour}
COMMENT=${3:-Added by $0 at $(date -R) - will expire at $SCHEDULE}
/sbin/iptables -I INPUT -s "$HOST" -j DROP -m comment --comment "$COMMENT"
at "$SCHEDULE" <<<"iptables -D INPUT -s $HOST -j DROP"
