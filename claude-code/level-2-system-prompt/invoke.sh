#!/usr/bin/env bash
# Launch Claude Code with a security-focused appended system prompt.
# DO NOT EXECUTE during the demo write-up — this is a demo artifact for the video.

cd "$(dirname "$0")"

claude --append-system-prompt "$(cat ./system-prompt.txt)"
