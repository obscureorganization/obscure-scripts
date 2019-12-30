#!/usr/bin/env bash
#
# icinga-watchdog.sh
#
# Ensure that your icinga2 server sends a custom notification every day
# to remind you that it is still alive.
#
# To use this, you should probably set up an additional API user for
# your icinga2 system in your icinga2 system's conf.d/api-users.conf
# (typically /etc/icinga2/conf.d/api-users.conf)
#
# You will want to mark your main icinga2 server with the following
# host variable in its configuration file:
#
#     vars.icinga = true
#
# This is needed so that the fil
#
# Set up a host group in your conf.d/host-groups.conf as follows:
#
#     object HostGroup "icinga-servers" {
#        display_name = "Icinga Servers"
# 
#        assign where host.vars.icinga
#      }
#     
# Set this up by copying this script to your /usr/local/bin directory,
# and then set the permissions so that the icinga user can read and
# execute it:
#
#    install icinga-watchdog.sh /usr/local/bin/icinga-watchdog.sh
# 
# Create a configuration file to ustomize the message and credentials,
# and put it in /etc/icinga2/icinga-watchdog.env:
#
#    vi /usr/local/bin/icinga-watchdog.sh
#
# Make the file contents something like this:
#
#    CREDENTIALS='watchdog:xxxxxxxxxxxxxyyyyyyyyyyyzzzzzz12'
#    CONTACT_NAME='Snafu Fubar'
#    CONTACT_PHONE='+1 555 555 1212'
#    export CREDENTIALS CONTACT_NAME CONTACT_PHONE
#
# Then add a crontab entry on your icinga server:
#
#    18 * * * * . /etc/icinga2/icinga-watchdog.env && /usr/local/bin/icinga-watchdog.sh
#
# Copyright (C) 2019 The Obscure Organization
#
# MIT licensed. See the LICENSE file for details.
#
# Release History:
#
# 1.0 (December 8, 2019)
#  First public release
# 1.1 (December 30, 2019)
#  Externalized config to env file

# Set unofficial bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x

AUTHOR=${AUTHOR:-watchdog}
HOST_GROUP=${HOST_GROUP:-icinga-servers}
CREDENTIALS=${CREDENTIALS:-watchdog:replace-me-with-a-real-password}
CONTACT_NAME=${CONTACT_NAME:-Ferd Berferd}
CONTACT_PHONE=${CONTACT_PHONE:-+1 555 555 1212}

MESSAGE="Hello again!\nThis is a daily reminder from the Icinga2 watchdog script that the system is working.\n\nIf you do not see this message once every day, something is wrong!\n\nIf the last message you see is older than 72 hours, please escalate to:\n\n$CONTACT_NAME\nvia mobile telephone: $CONTACT_PHONE\n\n\nThe script $0 on $(hostname) sends this alert."

exec curl -k -s -u "$CREDENTIALS" -H 'Accept: application/json'  -X POST 'https://localhost:5665/v1/actions/send-custom-notification'  -d '{ "type": "Host", "author": "'"$AUTHOR"'", "comment": "'"$MESSAGE"'", "force": true, "pretty": true, "filter": "\"'"$HOST_GROUP"'\" in host.groups"  }'
