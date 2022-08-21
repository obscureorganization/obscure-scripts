#!/usr/bin/env bash
# tiamat-install.sh
#
# Script used to set up tiamat.obscure.org after the catastropic
# failures of August 2022. Installs packages.
set -euo pipefail

packages='
bind
bind-chroot
dovecot
epel-release
git
httpd
httpd-tools
postgresql
postgresql-server
procmail
sendmail
'

dnf -y install $packages

extra_packages='
alpine'

dnf -y install $extra_packages
