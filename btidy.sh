#!/usr/bin/env bash
#
# btidy.sh
#
# Use HTML tidy on just the body of an HTML file.
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

echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' >> "$TMPFILE"

echo "<html><head><title>invisible</title></head><body>" >> "$TMPFILE"
FILE=$1
shift
cat "$FILE" >> "$TMPFILE"
# shellcheck disable=SC2048,SC2086
tidy -q --show-body-only y $* "$TMPFILE"
if [ $? -lt 2 ] && echo "$*" | grep -- '-m' > /dev/null; then
    cat "$TMPFILE" > "$FILE"
fi
#echo "grep exit: $?"
