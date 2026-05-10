# Claude Code — 5 Levels of Bash Security

Each subdirectory is a self-contained Claude Code project at the given security level. Open the level directory, populate `./target/` via the setup script, then launch `claude` from that directory.

| Level | Configuration | Where it lives |
|-------|---------------|----------------|
| 1 | `safe-mode` skill (user-channel) | `level-1-user-prompt/.claude/skills/safe-mode/SKILL.md` |
| 2 | `--append-system-prompt` flag | `level-2-system-prompt/invoke.sh` + `system-prompt.txt` |
| 3 | PreToolUse hook + `permissions.deny` blacklist | `level-3-blacklist/.claude/{settings.json,hooks/blacklist.py}` |
| 4 | PreToolUse hook + default-deny + curated whitelist | `level-4-whitelist/.claude/{settings.json,hooks/whitelist.py}` |
| 5 | Bash denied + minimal MCP server provides safe tools | `level-5-no-bash/safe_tools_mcp.py` (canonical) + `agent_sdk_demo.py` (variant) |

## Hook contract used at L3, L4, L5

Modeled on the [Damage Control codebase](https://github.com/disler/claude-code-damage-control):

- **stdin:** JSON `{"tool_name": "Bash", "tool_input": {"command": "..."}, ...}`
- **exit 0** → allow (or output JSON for `permissionDecision: "ask"`)
- **exit 2** → block; stderr message is shown back to the model
- Hook scripts use [Astral `uv`](https://docs.astral.sh/uv/) inline-script headers — no global Python install required

## How to run any level

```bash
cd level-N-<name>/
bash ../../setup-target.sh
claude
```
