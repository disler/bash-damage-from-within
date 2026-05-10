# Pi Agent Harness — 5 Levels of Bash Security

Pi exposes security primitives via TypeScript **extensions** registered to the `tool_call` event (and friends). Each level's `.pi/extensions/*.ts` file is auto-discovered when you launch `pi` from that directory.

| Level | Mechanism | Where it lives |
|-------|-----------|----------------|
| 1 | `safe-mode` skill (user-channel) | `level-1-user-prompt/.pi/skills/safe-mode/SKILL.md` |
| 2 | `--append-system-prompt` flag | `level-2-system-prompt/invoke.sh` + `system-prompt.txt` |
| 3 | `tool_call` extension with regex blacklist | `level-3-blacklist/.pi/extensions/blacklist.ts` |
| 4 | `tool_call` extension with default-deny whitelist | `level-4-whitelist/.pi/extensions/whitelist.ts` |
| 5 | `tool_call` always-blocks bash + `pi.registerTool()` for safe tools | `level-5-no-bash/.pi/extensions/no-bash.ts` |

## Pi `tool_call` event contract

```typescript
pi.on("tool_call", async (event, ctx) => {
  // event.toolName: "bash" | "read" | "edit" | "write" | "grep" | "find" | "ls"
  // event.input.command: bash command string (mutable)

  // Block:
  return { block: true, reason: "human-readable reason" };

  // Allow (no return needed):
  return undefined;
});
```

Verified against `examples/extensions/permission-gate.ts` shipped with `@mariozechner/pi-coding-agent` 0.70.6.

## How to run any level

```bash
cd level-N-<name>/
bash ../../setup-target.sh
pi
```

Pi auto-discovers `.pi/extensions/*.ts` and `.pi/AGENTS.md` / `.pi/SYSTEM.md` from the cwd.
