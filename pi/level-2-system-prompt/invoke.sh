#!/usr/bin/env bash
# Launch Pi with a security-focused appended system prompt.
# Architectural twin of claude-code/level-2-system-prompt/invoke.sh.

cd "$(dirname "$0")"

pi --append-system-prompt "$(cat ./system-prompt.txt)"
