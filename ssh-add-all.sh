#!/usr/bin/env sh
# ssh-add-all.sh
#
# Add all the SSH key files in your $HOME/.ssh/ directory
#
# Usage:

# Include this from your .profile
#     . $HOME/Documents/obscure-scripts/ssh-add.all.sh
alias ssh-add-all='ssh-add $(grep "PRIVATE KEY" "$HOME/.ssh/"* | cut -d: -f1 | sort -u)'
