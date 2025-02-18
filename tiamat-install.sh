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

packages='
bind
bind-chroot
boost-devel
certbot
certbot python3-certbot-apache
clamav
clamav-milter
clamav-update
clamd
cmake
dnf-automatic
dovecot
doxygen
emacs
epel-release
git
gmp-devel
httpd
httpd-tools
krb5-devel
libedit-devel
libtirpc-devel
links
mailman3
python3-mailman-web
python3-mailman-hyperkitty
man2html
mariadb
mariadb-server
mod_ssl
mpfr-devel
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
openarc
opendkim
opendkim-tools
pam-devel
php
php-gd
php-intl
php-pecl-zip
php-pgsql
postgresql
postgresql-server
procmail
s-nail
selinux-policy-devel
sendmail
sendmail-cf
spamassassin
sysbench
sysstat
tcsh
texinfo
texinfo-tex
texlive-cm-super
texlive-ec
texlive-eurosym
utf8cpp-devel
whois
'

extra_packages='
alpine
ntfs-3g
shellcheck
tidy'

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
# T
# Thanks https://linux.how2shout.com/enable-crb-code-ready-builder-powertools-in-almalinux-9/
# for the hint on how to enable crb to get texinfo and friends
dnf config-manager --set-enabled crb
#shellcheck disable=SC2086
dnf -y install $packages

#shellcheck disable=SC2086
dnf -y install $extra_packages

# Install ledger (built from SRPMS)
dnf -y install "$DIR/rpmbuild/RPMS/x86_64/ledger-3.2.1-13.el9.x86_64.rpm"

# Configure dnf-automatic
if [[ ! -f /etc/dnf/automatic.conf.dist ]]; then
    cp -a /etc/dnf/automatic.conf /etc/dnf/automatic.conf.dist
fi
sed -i'' -e 's/root@example.com/root@obscure.org/' /etc/dnf/automatic.conf

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
clamd@service
clamav-milter
dnf-automatic.timer
httpd
mailman3
mariadb
named
openarc
opendkim
postgresql
saslauthd
sendmail
spamassassin
'
for svc in $services; do
	systemctl enable "$svc"
	systemctl start "$svc"
done

# fix up smrsh so custom forward program will work with sendmail
rm -f /etc/smrsh/forward-spamfiltered
ln -s /usr/local/bin/forward-spamfiltered /etc/smrsh/forward-spamfiltered


# Adjust selinux
setsebool -P httpd_enable_homedirs true
setsebool -P httpd_can_network_connect_db true
setsebool -P httpd_can_sendmail true

selinux_mods='my-phpfpm
sendmail-spamc'

cd /root
cat > my-phpfpm.te <<EOF
module my-phpfpm 1.1;

require {
	type httpd_t;
	type pop_port_t;
	class tcp_socket name_connect;
}

#============= httpd_t ==============

#!!!! This avc is allowed in the current policy
allow httpd_t pop_port_t:tcp_socket name_connect;
EOF

cat > sendmail-spamc.te <<EOF
module sendmail-spamc 1.0;

require {
	type sendmail_t;
	type spamc_exec_t;
	class file { execute execute_no_trans getattr open read map };
}

#============= sendmail_t ==============
allow sendmail_t spamc_exec_t:file { execute execute_no_trans getattr open read };

#!!!! This avc can be allowed using the boolean 'domain_can_mmap_files'
allow sendmail_t spamc_exec_t:file map;
EOF

ls -l

for mod in $selinux_mods; do
    make -f /usr/share/selinux/devel/Makefile "$mod.pp"
    semodule -i "$mod.pp"
done

cd -

# Relink mail spool files
"$DIR/mail-symlink-inbox.sh"
