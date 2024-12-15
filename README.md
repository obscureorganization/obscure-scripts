Obscure Scripts
===============

A collection of scripts from [The Obscure Organization](https://www.obscure.org) - a public access UNIX system in continuous use since 1995.

## blockip.sh

[blockip.sh](blockip.sh) - Use iptables to temporarily block an IP addreess or CIDR block

### Description
This script uses iptables to temporarily block an IP address or CIDR block. It can be useful for mitigating unwanted traffic or attacks.

### Usage
```sh
./blockip.sh 192.2.0.0
./blockip.sh 192.2.0.1 now+1day
```
Symlink this into /usr/local/sbin to use it system-wide. To run with debugging information enabled:
```sh
DEBUG=true /usr/local/sbin/blockip.sh
```

## btidy.sh

[btidy.sh](btidy.sh) - Use [HTML tidy](https://www.html-tidy.org/) but only versus the body of an HTML file. Useful for filtering fragments of HTML files, or for using in vim (`:'a,'b ! btidy -wrap 0 -i -asxml`)

### Description
This script uses HTML tidy to clean up the body of an HTML file. It is useful for filtering fragments of HTML files or for use in vim.

### Usage
```sh
./btidy.sh <filename> [options] ...
```
From vi family editors, assuming btidy.sh is in your path:
```sh
:% ! btidy.sh [options]
:'a,'b ! btidy.sh -i
```

## cloud-init-centos-7-ipv6.yml

[cloud-init-centos-7-ipv6.yml](cloud-init-centos-7-ipv6.yml) - Use in instance data for CentOS 7.x EC2 servers that are having trouble getting an IPv6 default route. See also
[cloud-init-centos-7.6-ipv4-ena.yml](cloud-init-centos-7.6-ipv4-ena.yml) and [cloud-init-centos-7.6-ipv6-ena.yml](cloud-init-centos-7.6-ipv4-ena.yml)

### Description
This cloud-init configuration is intended for older CentOS 7.x EC2 instances that are having trouble getting an IPv6 default route. It includes specific configurations for the ENA adapter and other settings.

### Usage
Use this file as instance data when launching or configuring CentOS 7.x EC2 instances.

## icinga2-graceful.sh

[icinga2-graceful.sh](icinga2-graceful.sh) - Check the validity of icinga2 system configuration files, then restart it only if the configuration is ok.

### Description
This script validates the icinga2 configuration and restarts the service only if the configuration is valid. It helps prevent service disruptions due to invalid configurations.

### Usage
```sh
./icinga2-graceful.sh
```
To run with debugging information enabled:
```sh
DEBUG=true ./icinga2-graceful.sh
```

## icinga2-watchdog.sh

[icinga2-watchdog.sh](icinga2-watchdog.sh) - Ensure that an icinga2 system alerts once per day to let people know it is still alive - and where to complain if it is dead.

### Description
This script ensures that an icinga2 system sends a custom notification every day to remind you that it is still alive. It helps monitor the health of the icinga2 system.

### Usage
Configure an API user called "watchdog" in /etc/icinga2/conf.d/api-users.conf:
```sh
object ApiUser "watchdog" {
  password = "replace-me-with-a-real-password"
  permissions = [ "*" ]
}
```
Set up a host group in your conf.d/host-groups.conf:
```sh
object HostGroup "icinga-servers" {
  display_name = "Icinga Servers"
  assign where host.vars.icinga
}
```
Create a configuration file to customize the message and credentials, and put it in /etc/icinga2/icinga2-watchdog.env:
```sh
CREDENTIALS='watchdog:xxxxxxxxxxxxxyyyyyyyyyyyzzzzzz12'
CONTACT_NAME='Snafu Fubar'
CONTACT_PHONE='+1 555 555 1212'
```
Add a crontab entry on your icinga server:
```sh
0 16 * * * set -a && . /etc/icinga2/icinga2-watchdog.env && /usr/local/bin/icinga2-watchdog.sh
```

## imapd-reap-processes.sh

[imapd-reap-processes.sh](imapd-reap-processes.sh) - Kill off stale imapd processes that accumulate on a busy mail server

### Description
This script purges root-owned imapd processes that started and never got killed off. It helps save process slots and memory on a busy mail server.

### Usage
Create symlinks to activate this:
```sh
sudo ln -s $(pwd)/imapd-reap-processes.sh /usr/local/sbin/imapd-reap-processes.sh
sudo ln -s /usr/local/sbin/imapd-reap-processes.sh /etc/cron.daily/imapd-reap-processes
```

## patronus.sh

[patronus.sh](patronus.sh) - kill login sessions and processes on other ttys, with a whimsical magic twist. 

### Description
This script kills login sessions and processes on other ttys the way Harry Potter would have done it. It is a parody of J.K. Rowling's novels; this is perhaps one of the only works of fan fiction _or_ parody written in `bash`!. Originally [released under the GPLv3](https://obscurerichard.wordpress.com/2007/09/06/harry-potter-shell-script-fan-fiction-in-celebration-of-my-35th-birthday/), now relicensed under the MIT license, and updated to be [shellcheck clean](https://shellcheck.net).

### Usage
```sh
./patronus.sh
```
To run with debugging information enabled:
```sh
DEBUG=true ./patronus.sh
```

## run-sysbench.sh

[run-sysbench.sh](run-sysbench.sh) - Run [sysbench](https://github.com/akopytov/sysbench) with a standard set of options. Useful for collecting the same set of performance statistics on multiple hosts.

### Description
This script runs a complete suite of sysbench performance benchmarks. It is useful for collecting the same set of performance statistics on multiple hosts.

### Usage
```sh
./run-sysbench.sh <storage_type>
```
Replace `<storage_type>` with either `disk` or `ssd`.

## ssh-add-all.sh

[ssh-add-all.sh](ssh-add-ramdisk.sh) - Alias to add all your SSH keys from $HOME/.ssh/ with one command.

### Description
This script adds all your SSH keys from $HOME/.ssh/ with one command. It is useful for quickly adding multiple SSH keys to the SSH agent.

### Usage
```sh
./ssh-add-all.sh
```

## ssh-add-ramdisk.sh

* [ssh-add-ramdisk.sh](ssh-add-ramdisk.sh) - Keep your SSH keys on a USB key, but load them into a RAMDisk on macOS or Linux - so you don't have to keep permanent copies of the SSH keys on the systems you physically use, which is useful sometimes.

### Description
This script allows you to copy your SSH keys from removable media to a RAM disk and then adds the SSH keys to your current SSH agent keyring. It is useful for keeping your SSH keys secure and not leaving permanent copies on the systems you use.

### Usage
```sh
./ssh-add-ramdisk.sh
```
To remove the ramdisk:
```sh
./ssh-add-ramdisk.sh -r
```

## ssh-env.sh

* [ssh-env.sh](ssh-env.sh) - Use to help reconnect managed terminal sessions (think `screen` or `tmux`) terminals to your SSH key agent via environment manipulation.

### Description
This script helps propagate the SSH environment inside the current session. It is useful for reconnecting managed terminal sessions (e.g., `screen` or `tmux`) to your SSH key agent.

### Usage
```sh
./ssh-env.sh
```
Inside your .profile, .bash_profile, or .bash_login:
```sh
./ssh-env.sh
```
When running interactively in a tmux or screen session, include the output of ssh-env.sh and regain access to your SSH agent:
```sh
. ~/.ssh/env
```

## uptimerobot-firewall-update.sh

* [uptimerobot-firewall-update.sh](uptimerobot-firewall-update.sh) - Update firewall entries that allow [uptimerobot.com](https://www.uptimerobot.com/) to check otherwise resticted services. Uptime Robot is free and is suitable for small-scale monitoring as a primary service or as a secondary monitor that watches your primary monitoring system and most critical services.

### Description
This script updates the firewall entries to allow uptimerobot.com to check otherwise restricted services. It is useful for integrating Uptime Robot with your monitoring setup.

### Usage
Run this on a host that will be monitored through uptimerobot.com. Consider linking it into cron, for example:
```sh
sudo ln -s $PWD/uptimerobot-firewall-update.sh /etc/cron.weekly/
```

## tiamat-setup.sh

[tiamat-setup.sh](tiamat-setup.sh) - Set up packages and more on tiamat.obscure.org (emergency recovery script)

### Description
This script sets up packages and more on `tiamat.obscure.org`, the main server for [The Obscure Organization](https://www.obscure.org/). It is an emergency recovery script for setting up the system after catastrophic failures, and also gets used to install packages and configure the system on an intermittent basis.

### Usage
Run this script as root to set up the necessary packages and configurations on `tiamat.obscure.org`.

```sh
sudo ./tiamat-setup.sh
```

## watch-filevault-setup.sh

* [watch-filevault-setup.sh](watch-filevault-setup.sh) - Watch and log the filevault encryption process, which can take a really long time on an older Macintosh.

### Description
This script watches the progress of FileVault and logs the progress to a file. It is useful for monitoring the FileVault encryption process on macOS.

### Usage
```sh
./watch-filevault-setup.sh
```

Acknowledgements
----------------
Thanks go to Scott Hanselman for the [suggestion and instructions on switching the git default branch from master to main](https://www.hanselman.com/blog/EasilyRenameYourGitDefaultBranchFromMasterToMain.aspx). This repository transitioned to using `main` as its default branch on 2020-06-14.

Legal
-----
Copyright (C) 2020 by The Obscure Organization

MIT licensed. See [LICENSE](LICENSE) for details.
