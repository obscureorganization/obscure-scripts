#!/usr/bin/env bash
# uptimerobot-firewall-update.sh
#
# Updates the uptimerobot.com firewall entries
#
# Run this on a host that will be monitored through uptimerobot.com and
# consider linking it into cron, for example:
#
#     sudo ln -s $PWD/uptimerobot-firewall-update.sh /etc/cron.weekly/

# Set unofficial bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Thanks http://redsymbol.net/articles/bash-exit-traps/
scratch=$(mktemp -t uptimerobot.XXXXXXXXXX)
function finish {
  retcode=$?
  if [[ $retcode -ne 0 ]]; then
        cat "$scratch"
        echo "ERROR: return code: $retcode"
  fi
  rm -f "$scratch"
  exit $retcode
}
trap finish EXIT

(
    zone=uptimerobot
    if ! firewall-cmd --list-all --zone "$zone"; then
        firwall-cmd --new-zone "$zone" --permanent
        systemctl restart firewalld
    fi

    for perm in "" "--permanent"; do
        firewall-cmd --zone "$zone" --add-service ssh $perm
        firewall-cmd --zone "$zone" --add-port 5665/tcp $perm # icinga2 api
        curl -s https://uptimerobot.com/inc/files/ips/IPv4andIPv6.txt | 
            sed 's/\r//g' | 
            while read source; do 
                firewall-cmd --zone "$zone" --add-source "$source" $perm
            done
    done
) > "$scratch" 2>&1

