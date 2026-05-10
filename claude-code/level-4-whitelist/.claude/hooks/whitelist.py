# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""
Level 4: Bash whitelist — default-deny PreToolUse hook for Claude Code.

Only commands matching one of the curated regex patterns may run. Compound
shell operators are rejected before pattern matching to prevent
allowlisted-prefix abuse like `npm test && rm -rf target`.

Hook contract:
  stdin:  JSON with tool_name, tool_input.command, etc.
  exit 0: allow
  exit 2: block (stderr message shown to Claude)
"""

import json
import re
import sys

# Each entry is an anchored regex. The command must match ONE of these exactly.
# Tighten or loosen for your project, but: NEVER let an agent expand this list.
WHITELIST = [
    r"^pwd$",
    r"^ls(\s+-[la]+)?(\s+[\w./\-]+)?$",
    r"^cat\s+[\w./\-]+\.(md|txt|json)$",
    r"^npm\s+(test|run\s+\w+)$",
    r"^pnpm\s+(test|run\s+\w+)$",
    r"^uv\s+run\s+pytest(\s+-[\w\-]+)*(\s+[\w./\-]+)?$",
    r"^uv\s+run\s+ruff\s+(check|format)(\s+\.|\s+[\w./\-]+)?$",
    r"^git\s+(status|log|diff|branch|show)(\s+[\w./\-]+)?$",
    r"^node\s+--version$",
    r"^python3?\s+--version$",
]

# Reject anything containing command separators — even if a sub-command
# would individually match. This prevents `npm test && rm -rf target`.
SHELL_OPERATORS = re.compile(r"(&&|\|\||;|\||`|\$\(|>|<)")


def main() -> None:
    try:
        event = json.load(sys.stdin)
    except json.JSONDecodeError as exc:
        print(f"whitelist.py: invalid JSON input: {exc}", file=sys.stderr)
        sys.exit(1)

    if event.get("tool_name") != "Bash":
        sys.exit(0)

    command = (event.get("tool_input", {}).get("command", "")).strip()
    if not command:
        sys.exit(0)

    if SHELL_OPERATORS.search(command):
        print(
            f"BLOCKED (Level 4 whitelist): compound/chained command\n"
            f"  Command: {command[:160]}",
            file=sys.stderr,
        )
        sys.exit(2)

    for pattern in WHITELIST:
        if re.match(pattern, command):
            sys.exit(0)

    print(
        f"BLOCKED (Level 4 whitelist): command not in allowlist\n"
        f"  Command: {command[:160]}\n"
        f"  Tip: only commands matching one of {len(WHITELIST)} curated patterns may run.",
        file=sys.stderr,
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
