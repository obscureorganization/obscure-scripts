#!/usr/bin/env bash
# cert-notifier.sh
# After renewing SSL certificates with Certbot we need to copy
# them to the locations that Sendmail and Dovecot use, and then
# restart those subsystems.
# 
# Configure this in /etc/sysconfig/certbot

# Set unofficial bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x

cp /etc/letsencrypt/live/obscure.org/privkey.pem  /etc/pki/dovecot/private/dovecot.pem
cp /etc/letsencrypt/live/obscure.org/fullchain.pem  /etc/pki/dovecot/certs/dovecot.pem
cp /etc/letsencrypt/live/obscure.org/privkey.pem /etc/pki/tls/private/sendmail.key
cp /etc/letsencrypt/live/obscure.org/fullchain.pem  /etc/pki/tls/certs/sendmail.pem
systemctl restart sendmail
systemctl restart dovecot
