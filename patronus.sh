#!/usr/bin/env bash
#
# patronus.sh
#
# Dispel ghost logins that suck the joy out of your active terminal session
#
# Copyright (C) 2007 Richard Bullington-McGuire
# Copyright (C) 2019 The Obscure Organization
# Many thanks (and aplologies) to J.K. Rowling
#
# DISCLAIMER
#   This is a parody of J.K. Rowling's Harry Potter novels. 
#   Lawyers: please don't sue this poor house-elf who is only trying to help.
#
# Copyright (C) 2019 by The Obscure Organization
# MIT licensed. See the LICENSE file for details.
#
# Release History:
#
# 1.0 (September 6, 2007)
#  First public release
#
# 1.0.1 (May 19, 2019)
#  Relicensed under the MIT license
#
# 1.0.2 (May 19, 2019)
#  Lint fixes: now ShellCheck clean  (see https://www.shellcheck.net)

# Set unofficial bash strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x

# Thanks http://redsymbol.net/articles/bash-exit-traps/
function finish {
  rm -rf "$FLOO_NETWORK" "$MAGICAL_CREATURES"
}
trap finish EXIT

MAGICAL_CREATURES=$(mktemp -t patronus.XXXXXXXXXX)
FLOO_NETWORK=$(mktemp -t patronus.XXXXXXXXXX)
DEMENTORS=""
printf "Lumos!\n"

ps x > "$MAGICAL_CREATURES"


FLOO_EXITS=$(egrep " *$$" "$MAGICAL_CREATURES" | \
    awk '{print $2}')
if awk '!/ PID/{print $2}' < "$MAGICAL_CREATURES" | \
    sort -u |
    egrep -v "^\?|$FLOO_EXITS" > "$FLOO_NETWORK"; then
    DEMENTORS=$(cat "$FLOO_NETWORK")
fi
echo "$DEMENTORS"

if [ -z "$DEMENTORS" ] ; then
    echo "No dementors spotted nearby."
else
    DEMENTOR_KISSES=$(grep -f "$FLOO_NETWORK" < "$MAGICAL_CREATURES" | \
        awk '{print $1}')
    DEMENTOR_DESCRIPTION=$(ps u $DEMENTOR_KISSES)

    cat << EOT
Traversing floo network at $FLOO_EXITS, dementors spotted at: 
$DEMENTORS

Specialis Revelio!
    
Dementors found: 
$DEMENTOR_DESCRIPTION

EXPECTO PATRONUM!
EOT
    kill -HUP $DEMENTOR_KISSES 2>/dev/null
fi
