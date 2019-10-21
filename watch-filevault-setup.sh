#!/usr/bin/env bash
# watch-filevalult-setup.sh
#
# On macOS, watch the progress of FileVault and log the progress to a file.
#
# Copyright (C) 2019 by The Obscure Organization
# MIT licensed. See the LICENSE file for details.

# Set unofficial bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

LOGFILE="$HOME/fdesetup-status.txt"
INTERVAL=1800 # 1800 seconds is 30 minutes

watch -n "$INTERVAL" '
    printf "Logging FileVault setup progress to '"$LOGFILE"'\n\n";
    (
        (
            date -R 
            fdesetup status
        ) | tr "\n" " "
        printf "\n"
    ) | tee -a '"$LOGFILE"
