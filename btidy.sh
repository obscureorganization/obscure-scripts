#!/usr/bin/env bash
#
# btidy.sh
#
# Use HTML tidy on just the body of an HTML file.
# See https://www.html-tidy.org/ for documentation on tidy.
#
# Usage:
#     btidy <filename> [options] ...
#
# Copyright (C) 2024 by The Obscure Organization
#
# MIT licensed. See the LICENSE file for details.
#
# Release History:
#
# 1.0 (Sat Dec 14, 2024)
#  First public release

# Use bash unofficial strict mode
set -euo pipefail
IFS=$'\n\t'

TMPFILE=$(mktemp /tmp/btidy.XXXXXX)

# remove tempfile on exit
function finish {
  rm -f "$TMPFILE"
}
trap finish EXIT

# Nice, thanks https://www.cyberciti.biz/faq/linux-unix-bsd-apple-osx-bash-get-last-argument/
FILE="${BASH_ARGV[0]}"
#FILE=${1:-/dev/stdin}
# If a file is specified as the first CLI option, consume the first parameter
if [ -f "$FILE" ]; then
    # tricksy - thanks https://unix.stackexchange.com/a/273531
    ARGS="${@:1:$#-1}"
fi
cat <<EOF > "$TMPFILE"
<!doctype html>
<html><head><title>invisible</title></head>
<body>
EOF
cat "$FILE" >> "$TMPFILE"
# shellcheck disable=SC2048,SC2086
tidy -q --show-body-only y $ARGS "$TMPFILE"
if [ $? -lt 2 ] && echo "$ARGS" | grep --quiet -- '-m'; then
    cat "$TMPFILE" > "$FILE"
fi
#echo "grep exit: $?"
