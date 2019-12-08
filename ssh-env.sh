#!/usr/bin/env bash
#
# ssh-env.sh
#
# Propagate ssh environment inside current session
#
# This helps work around the issue people face when they return
# to a tmux or screen session, and need to use the SSH authentication
# agent to authenticate or further forward the agent connection.
# Typically the SSH variables are stale and attempting to use the
# agent will fail.
#
# Source 'ssh-env' inside your tmux or screen session and this will
# refresh the environment variables Useful for running inside screen or tmux after 
#
# Run this with the -l parameter in your .profile or other
# shell startup script. That will copy the SSH_CONNECTION and
# SSH_AUTH_SOCK environment variables into $HOME/.ssh/.envrc
#
# Usage:
#
#    ssh-env.sh
#
# Inside your .profile, .bash_profile, or .bash_login:
#
#    ssh-env.sh
#
# When running interactively in a tmux or screen session, include
# the output of ssh-env.sh and regain access to your SSH agent:
#
#    . ~/.ssh/env
#
# Copyright (C) 2019 The Obscure Organization
#
# MIT licensed. See the LICENSE file for details.
#
# Release History:
#
# 1.0 (June 1, 2019)
#  First public release
# 1.1 (December 7, 2019)
#  Improved documentation

DEBUG=${DEBUG:-false}

# Thanks https://stackoverflow.com/a/16496491
function usage {
    echo "Usage: $0 [-h] [-v]"
}

verbose=''

set +u
while getopts ":hlv" args; do
    case "${args}" in
        h)
            usage
            ;;
        v)
            DEBUG='true'
            verbose='-v'
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

# Thanks https://stackoverflow.com/a/17805088
$DEBUG && export PS4='${LINENO}: ' && set -x
finish () {
    $DEBUG && set +x
}
trap finish EXIT

$DEBUG && echo "args: login $login / verbose $verbose"

SSHENV="$HOME/.ssh/env"
cat > "$SSHENV" <<EOF
#!/usr/bin/env bash
#
# SSH env file
#
# See ssh-env
#
# Source this with
#    . ~/.ssh/env
#
set -a
SSH_CONNECTION="$SSH_CONNECTION"
SSH_AUTH_SOCK="$SSH_AUTH_SOCK"
set +a
EOF
