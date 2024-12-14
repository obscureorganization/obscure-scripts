#!/usr/bin/env bash
#
# btidy.sh
#
# Use HTML tidy on just the body of an HTML file.
# See https://www.html-tidy.org/ for documentation on tidy.
#
# When used as a filter, this will enclose each line of tidy output in
# an HTML comment.
#
# Usage:
#     ./btidy.sh <filename> [options] ...
#
#     # From vi family editors, assuming btidy.sh is in your path:
#     :% ! btidy.sh [options]
#     # vi example in a marked section:
#     :'a,'b ! btidy.sh -i
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

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x

TMPFILE=$(mktemp /tmp/btidy.XXXXXX)
TMPERR=$(mktemp /tmp/btidy-err.XXXXXX)
TMPOUT=$(mktemp /tmp/btidy-out.XXXXXX)

# remove tempfile on exit
function finish {
  rm -f "$TMPFILE" "$TMPERR"
}
trap finish EXIT

# Nice, thanks https://www.cyberciti.biz/faq/linux-unix-bsd-apple-osx-bash-get-last-argument/
FILE="${BASH_ARGV[0]:-}"
if [ -z "$FILE" ]; then
    ARGS="$*"
    FILE=/dev/stdin
elif [ -f "$FILE" ]; then
    # If a file is specified as the last CLI option, consume the last parameter
    # tricksy - thanks https://unix.stackexchange.com/a/273531
    # shellcheck disable=2124
    ARGS="${@:1:$#-1}"
else
    ARGS="$*"
    FILE=/dev/stdin
fi

cat <<EOF > "$TMPFILE"
<!doctype html>
<html><head><title>invisible</title></head>
<body>
EOF
cat "$FILE" >> "$TMPFILE"
set +e
# shellcheck disable=SC2048,SC2086
tidy -q --show-body-only y $ARGS "$TMPFILE" > "$TMPOUT" 2>"$TMPERR"
EXITCODE=$?
set -e

if [[ "$EXITCODE" -gt 0 ]]; then
    echo "WARNING: tidy had non-zero exit $EXITCODE" >> "$TMPERR"
fi
if [[ "$FILE" != "/dev/stdin"  ]] \
    && echo "$ARGS" | grep --quiet -E -- '-m|--modify'
then
    cat "$TMPFILE" > "$FILE"
else
    if [[ -s "$TMPERR" ]]; then
        TV="$(tidy --version)"
        printf '<!-- %s -->\n' "$TV"
        sed 's/^\(.*\)$/<!-- \1 -->/' "$TMPERR"
    fi
    cat "$TMPOUT"
fi

exit $EXITCODE
