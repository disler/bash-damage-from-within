# Pi — Level 4: Bash + Whitelist

Same architecture as Claude Code L4 but in Pi extension form. Default-deny via `tool_call`; only the listed regex patterns pass. Compound shell operators (&&, ||, ;, |, redirects) are rejected before pattern matching.

## How to run

```bash
cd <this dir>
bash ../../setup-target.sh
pi
```

## Files

- `.pi/extensions/whitelist.ts` — auto-discovered extension

## Try to break it

Identical outcomes to Claude Code L4: chained, encoded, and renamed-binary attacks all fail at the SHELL_OPERATORS check or the default-deny.

## Subtle failure modes

- Whitelist drift — adding `^bash .*\.sh$` lets the agent script its way around
- A whitelisted command with destructive flags (`git clean -fdx` if `git\s+.*` is listed)
- Inputs to whitelisted commands — `^uv\s+run\s+[\w./\-]+\.py$` allows running ANY `.py` file the agent writes

**Curate the list yourself; never let another agent expand it.**

## Move up

Level 5 removes bash entirely.
