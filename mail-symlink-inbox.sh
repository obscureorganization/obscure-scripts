#!/usr/bin/env bash
# mail-symlink-inbox.sh
#
# Copyright (C) 2022 The Obscure Organization
#
# MIT licensed. See the LICENSE file for details.

set -euo pipefail

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x

# Symlink /home/user/mail/inbox to /var/spol/mail/inbox
# This lets dovecot autodetect the ~/mail directory - needed
# as part of the emergency migration to Obscure's new server.
# It is going to be hard to get uw-imap back because xinetd won't compile on RHEL 9 derivatives,
# so everyone is going to use Dovecot going forward.
#
# To get Dovecot to auto-detect an inbox it needs to see one of the files
# listed in Autodetection in 
# https://doc.dovecot.org/configuration_manual/mail_location/
cd /home
find . -maxdepth 2 -type d -name mail | while read -r mailuser; do
    $DEBUG && echo -n "mailuser:$mailuser"
    user=$(cut -d/ -f2 <<<"$mailuser")
    $DEBUG && echo "user:$user"
    mail="/home/$user/mail"
    inboxlink="$mail/inbox"
    varspool="/var/spool/mail/$user"
    if [ -d "$mail" ] && [ ! -f "$inboxlink" ]; then
        $DEBUG && echo ln -s "$varspool" "$inboxlink"
        ln -s "$varspool" "$inboxlink"
        chown "$user" "$inboxlink"
    else
        $DEBUG && echo "$user did not qualify"
    fi
done
exit 0
