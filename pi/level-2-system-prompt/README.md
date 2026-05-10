# Pi — Level 2: System Prompt Append

## What this level does

Uses Pi's `--append-system-prompt` flag to inject security rules into the system prompt rather than user-facing context. The system prompt has higher behavioral weight than `AGENTS.md`, so the model is more reliably aligned. Still: zero enforcement.

This is the **architectural twin** of Claude Code Level 2 — both harnesses now use the same `--append-system-prompt` mechanism. The demo cuts side-by-side cleanly.

## How to run

```bash
cd <this dir>
bash ../../setup-target.sh
bash invoke.sh        # runs: pi --append-system-prompt "$(cat system-prompt.txt)"
```

## Files

- `system-prompt.txt` — the security clauses appended to Pi's default system prompt
- `invoke.sh` — wrapper that launches Pi with the flag set

## Try to break it

Same outcomes as Claude Code L2: refusals are slightly stronger on direct asks, encoded-script attack still wins.

## Why this fails

Same as Claude Code L2: relying on the model to refuse. Capability scales both ways.

## Move up

Level 3 stops trusting the model and adds the first real enforcement: a `tool_call` extension that intercepts dangerous bash commands before they run.
