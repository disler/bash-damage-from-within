# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""
Level 3: Bash blacklist — PreToolUse hook for Claude Code.

Inspired by IndyDevDan's claude-code-damage-control:
  https://github.com/disler/claude-code-damage-control

Hook contract:
  stdin:  JSON with tool_name, tool_input.command, etc.
  exit 0: allow
  exit 2: block (stderr message shown to Claude)
"""

import json
import re
import sys

# Patterns we BLOCK. Curated for the demo — production lists are much longer.
BLACKLIST = [
    (r"\brm\s+(-[rRf]+|--recursive|--force)\b", "rm with recursive/force flags"),
    (r"\brm\s+/\b", "rm targeting root paths"),
    (r"\bsudo\b", "sudo escalation"),
    (r"\bchmod\s+(-R\s+)?[0-7]*7[0-7]{2}\b", "world-writable chmod"),
    (r"\b(aws|gcloud|vercel)\s+", "cloud CLI"),
    (r"\bcurl\s+.*\|\s*(sh|bash|zsh)\b", "curl piped to shell"),
    (r"\bgit\s+reset\s+--hard\b", "git destructive reset"),
    (r"\bgit\s+push\s+(-f|--force)(?!-with-lease)\b", "git force-push without lease"),
    (r"\bdd\s+if=.*of=/dev/", "dd to device"),
    (r"\bmkfs\.", "mkfs"),
    (r"\b:\(\)\s*\{", "fork bomb"),
    # Path-specific: anything touching ./target/secrets.env
    (r"target/secrets\.env\b", "secrets.env access via bash"),
]


def main() -> None:
    try:
        event = json.load(sys.stdin)
    except json.JSONDecodeError as exc:
        print(f"blacklist.py: invalid JSON input: {exc}", file=sys.stderr)
        sys.exit(1)

    if event.get("tool_name") != "Bash":
        sys.exit(0)

    command = event.get("tool_input", {}).get("command", "")
    if not command:
        sys.exit(0)

    for pattern, label in BLACKLIST:
        if re.search(pattern, command, re.IGNORECASE):
            print(
                f"BLOCKED (Level 3 blacklist): {label}\n"
                f"  Matched pattern: {pattern}\n"
                f"  Command:         {command[:160]}{'...' if len(command) > 160 else ''}",
                file=sys.stderr,
            )
            sys.exit(2)

    sys.exit(0)


if __name__ == "__main__":
    main()
