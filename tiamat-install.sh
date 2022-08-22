#!/usr/bin/env bash
# tiamat-install.sh
#
# Script used to set up tiamat.obscure.org after the catastropic
# failures of August 2022. Installs packages.
set -euo pipefail

config_network=true
primary_int=enp89s0
primary_int=$primary_int

packages='
bind
bind-chroot
dovecot
epel-release
git
httpd
httpd-tools
mod_ssl
nmstate
php
postgresql
postgresql-server
procmail
sendmail
whois
'

extra_packages='
alpine'


# Install packages
dnf -y install $packages

dnf -y install $extra_packages

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
firewall-cmd --zone=public --add-service dns
firewall-cmd --zone=public --add-service http
firewall-cmd --zone=public --add-service https
firewall-cmd --runtime-to-permanent

# Start services
services='
httpd
named
'
for svc in $services; do
	systemctl enable $svc
	systemctl start $svc
done

# Adjust selinux
setsebool -P httpd_enable_homedirs true
