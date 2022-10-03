#!/usr/bin/env bash
# tiamat-install.sh
#
# Script used to set up tiamat.obscure.org after the catastropic
# failures of August 2022. Installs packages.
set -euo pipefail

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x

# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Thanks https://askubuntu.com/a/15856
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

config_network=true
primary_int=enp89s0
primary_int=$primary_int

packages='
bind
bind-chroot
dovecot
certbot
clamav
cmake
emacs
epel-release
git
httpd
httpd-tools
krb5-devel
mariadb
mariadb-server
mod_ssl
mutt
nagios-plugins
nagios-plugins-disk
nagios-plugins-load
nagios-plugins-mysql
nagios-plugins-pgsql
nagios-plugins-procs
nagios-plugins-smtp
nagios-plugins-swap
nagios-plugins-users
nmstate
nrpe
pam-devel
php
php-gd
php-intl
php-pecl-zip
php-pgsql
postgresql
postgresql-server
procmail
certbot python3-certbot-apache
sendmail
sendmail-cf
spamassassin
s-nail
sysstat
tcsh
whois
'

extra_packages='
alpine'

firewall_services_allow='
dns
http
https
imap
imaps
pop3
pop3s
smtp
smtp-submission
smtps
'


# Install packages
#shellcheck disable=SC2086
dnf -y install $packages

#shellcheck disable=SC2086
dnf -y install $extra_packages

dnf -y --enablerepo=crb install libtirpc-devel

# Configure network

if "$config_network"; then
	# Thanks https://www.linuxtechi.com/set-static-ip-address-on-rhel-9/
	nmcli con modify "$primary_int" ifname $primary_int ipv4.method manual ipv4.addresses 71.163.169.18/24 gw4 71.163.169.1
	nmcli con modify "$primary_int" ipv4.dns 127.0.0.1
	nmcli con down "$primary_int"
	nmcli con up "$primary_int"
fi


# Fix up firewall
systemctl restart firewalld
for svc in $firewall_services_allow; do
    firewall-cmd --zone=public --add-service "$svc"
done
firewall-cmd --zone=public --add-port 10110/tcp
firewall-cmd --zone=public --add-port 10143/tcp
firewall-cmd --zone=public --add-port 10993/tcp
firewall-cmd --zone=public --add-port 10995/tcp
firewall-cmd --zone=public --add-masquerade
firewall-cmd --zone=public --add-forward-port=port=10110:proto=tcp:toport=110
firewall-cmd --zone=public --add-forward-port=port=10143:proto=tcp:toport=143
firewall-cmd --zone=public --add-forward-port=port=10993:proto=tcp:toport=993
firewall-cmd --zone=public --add-forward-port=port=10995:proto=tcp:toport=995

firewall-cmd --runtime-to-permanent

# Start services
services='
httpd
mariadb
named
postgresql
saslauthd
sendmail
spamassassin
'
for svc in $services; do
	systemctl enable "$svc"
	systemctl start "$svc"
done

# Adjust selinux
setsebool -P httpd_enable_homedirs true
setsebool -P httpd_can_network_connect_db true
setsebool -P httpd_can_sendmail true

# Relink mail spool files
"$DIR/mail-symlink-inbox.sh"
