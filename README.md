Obscure Scripts
===============

A collection of scripts from [The Obscure Organization](https://www.obscure.org) - a public access UNIX system in continuous use since 1995.

* [blockip.sh](blockip.sh) - Use iptables to temporarily block an IP addreess or CIDR block
* [cloud-init-centos-7-ipv6.yml](cloud-init-centos-7-ipv6.yml) - Use in instance data for CentOS 7.x EC2 servers that are having trouble getting an IPv6 default route. See also
[cloud-init-centos-7.6-ipv4-ena.yml](cloud-init-centos-7.6-ipv4-ena.yml) and [cloud-init-centos-7.6-ipv6-ena.yml](cloud-init-centos-7.6-ipv4-ena.yml)
* [icinga2-graceful.sh](icinga2-graceful.sh) - Check the validity of icinga2 system configuration files, then restart it only if the configuration is ok.
* [icinga2-watchdog.sh](icinga2-watchdog.sh) - Ensure that an icinga2 system alerts once per day to let people know it is still alive - and where to complain if it is dead.
* [imapd-reap-processes.sh](imapd-reap-processes.sh) - Kill off stale imapd processes that accumulate on a busy mail server
* [patronus.sh](patronus.sh) - kill login sessions and processes on other ttys, with a whimsical Harry Potter twist. This might be one of the only works of fan fiction parody written in `bash`!. Originally [released under the GPLv3](https://obscurerichard.wordpress.com/2007/09/06/harry-potter-shell-script-fan-fiction-in-celebration-of-my-35th-birthday/), now relicensed under the MIT license, and updated to be shellcheck clean.
* [run-sysbench.sh](run-sysbench.sh) - Run [sysbench](https://github.com/akopytov/sysbench) with a standard set of options. Useful for collecting the same set of performance statistics on multiple hosts.
* [ssh-add-all.sh](ssh-add-ramdisk.sh) - Alias to add all your SSH keys from $HOME/.ssh/ with one command.
* [ssh-add-ramdisk.sh](ssh-add-ramdisk.sh) - Keep your SSH keys on a USB key, but load them into a RAMDisk on macOS or Linux - so you don't have to keep permanent copies of the SSH keys on the systems you physically use, which is useful sometimes.
* [ssh-env.sh](ssh-env.sh) - Use to help reconnect managed terminal sessions (think `screen` or `tmux`) terminals to your SSH key agent via environment manipulation.
* [uptimerobot-firewall-update.sh](uptimerobot-firewall-update.sh) - Update firewall entries that allow [uptimerobot.com](https://www.uptimerobot.com/) to check otherwise resticted services. Uptime Robot is free and is suitable for small-scale monitoring as a primary service or as a secondary monitor that watches your primary monitoring system and most critical services.
* [watch-filevault-setup.sh](wuhatch-filevault-setup.sh) - Watch and log the filevault encryption process, which can take a really long time on an older Macintosh.

Legal
=====

Copyright (C) 2020 by The Obscure Organization

MIT licensed. See [LICENSE](LICENSE) for details.
