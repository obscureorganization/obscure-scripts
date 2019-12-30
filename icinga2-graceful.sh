#!/usr/bin/env bash
#
# icinga2-graceful.sh
#
# Inspired by the "apache2ctl graceful" option, this validates that an
# icinga2 configuration is valid before it restarts it.
#
# Copyright (C) 2019 The Obscure Organization
#
# MIT licensed. See the LICENSE file for details.
#
# Release History:
#
# 1.0 (December 8, 2019)
#  First public release

# Set unofficial bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x

sudo icinga2 daemon --validate
sudo systemctl restart icinga2
$DEBUG && systemctl status icinga2
