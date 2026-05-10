---
description: Install Bash: Damage From Within demo codebase — prerequisites (just, uv, claude, pi, node), executable bits, and target-asset readiness.
---

# Install Bash: Damage From Within

## Purpose

Set up the Damage From Within demo codebase for runnable side-by-side demos at all five security levels for both Claude Code and Pi. Verifies the toolchain (`just`, `uv`, `claude`, `pi`, `node`), sets executable bits on hook scripts and helpers, populates each level's `target/` dir from the shared template, and confirms launch readiness — without starting any agent. Interactive — ask the user when choices arise.

## Variables

SOURCE_REPO: the directory this command runs from (project root)
TARGET_TEMPLATE: `$SOURCE_REPO/target-template`
LEVELS: `claude-code/level-{1..5}-*` and `pi/level-{1..5}-*`

## Instructions

- Run every prerequisite check via `command -v` over Bash.
- Show a status line for each check (✓ or ✗) — clear visual signal.
- For missing tools with a canonical installer, offer to run it; never run auth/login flows on the user's behalf.
- Do NOT read or display API key values.
- Do NOT start any agent. Install proves readiness, not execution.
- Critical tools (`just`, `claude`, `pi`, `uv`) must gate — stop and guide if missing.

## Workflow

### Step 1 — Check Prerequisites

Critical (gate; stop with guidance if any are missing):

| Tool | Why | Install |
|---|---|---|
| `just` | task runner for every demo recipe | `brew install just` |
| `claude` | Claude Code CLI (cc-1 .. cc-5) | `npm i -g @anthropic-ai/claude-code` (or see https://docs.claude.com/cli) |
| `pi` | Pi agent harness (pi-1 .. pi-5) | `npm i -g @mariozechner/pi-coding-agent` |
| `node` | runtime required by `pi` | `brew install node` |
| `uv` | runs Claude Code hooks (inline `uv run --script` headers), the MCP server, and the Agent SDK demo | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |

Optional:
- `tmux` — `brew install tmux` (only needed if you'll script demos via `/drive`)

For each, run `command -v <tool>` and print `✓ <tool>` or `✗ <tool> — install: <cmd>`. If any critical tool is missing, stop and print the install commands.

### Step 2 — Set Executable Bits

The hook scripts and helpers must be executable:

```bash
cd "$SOURCE_REPO"
chmod +x setup-target.sh
chmod +x claude-code/level-2-system-prompt/invoke.sh
chmod +x pi/level-2-system-prompt/invoke.sh
find claude-code -type f -name '*.py' -exec chmod +x {} \;
```

Report each path that was touched.

### Step 3 — Populate Target Directories

Run the `just` helper to populate `./target/` in every level dir from `target-template/`. Idempotent — safe to re-run.

```bash
just reset
```

Confirm via `just status` that all 10 level dirs report 4 files in their `target/`.

### Step 4 — Verify Configuration

Confirm essential files exist and parse:

- `target-template/{production.db, customer_data.json, secrets.env, README.md}` — the source of truth for every level's `target/`
- `claude-code/level-3-blacklist/.claude/settings.json` — valid JSON, contains `permissions.deny` and a `PreToolUse` hook entry
- `claude-code/level-4-whitelist/.claude/settings.json` — valid JSON, contains `permissions.deny: ["Bash(*)"]` and a `PreToolUse` hook entry
- `claude-code/level-5-no-bash/.claude/settings.json` — valid JSON, contains a comprehensive `permissions.deny` plus `permissions.allow` and `enableAllProjectMcpServers: true`
- `claude-code/level-5-no-bash/.mcp.json` — valid JSON, contains `mcpServers.safe-tools` with `type: stdio`
- `claude-code/level-5-no-bash/safe_tools_mcp.py` — present
- `claude-code/level-5-no-bash/agent_sdk_demo.py` — present
- `claude-code/level-{3,4}-*/.claude/hooks/*.py` — present and executable
- `pi/level-{3,4,5}-*/.pi/extensions/*.ts` — present
- `pi/level-{1,2}-*/.pi/skills/safe-mode/SKILL.md` and `claude-code/level-1-user-prompt/.claude/skills/safe-mode/SKILL.md` — present

For each settings.json, validate with `python3 -c "import json; json.load(open('<path>'))"`. Report ✓/✗ per file.

### Step 5 — Verify Readiness

Confirm the launch surface parses without booting anything:

```bash
just --list      # all recipes parse
just status      # target/ contents across all 10 levels
```

The `just --list` output should show: `cc-1, cc-2, cc-3, cc-4, cc-5, cc-5-agent-sdk, pi-1, pi-2, pi-3, pi-4, pi-5` plus helpers (`doctor`, `status`, `reset`, `attack`).

### Step 6 — Report

Print a status table with each check's pass/fail. Show the ready count, e.g. `27 / 27 checks passed.`

Then print the concrete next steps (copy-pasteable):

```bash
just              # list all recipes
just doctor       # one-shot toolchain re-check
just cc-1         # boot Claude Code at Level 1 (safe-mode skill)
just pi-3         # boot Pi at Level 3 (blacklist hook extension)
just cc-5         # boot Claude Code at Level 5 (canonical: MCP server, no bash)
just attack 2     # copy attack prompt #2 to clipboard for pasting into the agent
```
