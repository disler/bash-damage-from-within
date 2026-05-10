/**
 * Level 4: Bash whitelist — Pi tool_call extension.
 *
 * Default-deny: only commands matching one of the curated allowlist patterns
 * are allowed through. Compound shell operators (&&, ||, ;, |, backticks,
 * $(...), redirects) are rejected to prevent allowlisted-prefix abuse.
 *
 * Auto-discovered when present in .pi/extensions/.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

// Anchored patterns — the command must match one fully.
const WHITELIST: RegExp[] = [
  /^pwd$/,
  /^ls(\s+-[la]+)?(\s+[\w./\-]+)?$/,
  /^cat\s+[\w./\-]+\.(md|txt|json)$/,
  /^npm\s+(test|run\s+\w+)$/,
  /^pnpm\s+(test|run\s+\w+)$/,
  /^uv\s+run\s+pytest(\s+-[\w\-]+)*(\s+[\w./\-]+)?$/,
  /^uv\s+run\s+ruff\s+(check|format)(\s+\.|\s+[\w./\-]+)?$/,
  /^git\s+(status|log|diff|branch|show)(\s+[\w./\-]+)?$/,
  /^node\s+--version$/,
  /^python3?\s+--version$/,
];

const SHELL_OPERATORS = /(&&|\|\||;|\||`|\$\(|>|<)/;

export default function whitelistExtension(pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash") return undefined;

    const command = ((event.input?.command as string) ?? "").trim();
    if (!command) return undefined;

    if (SHELL_OPERATORS.test(command)) {
      return {
        block: true,
        reason: `Level 4 whitelist: compound/chained command rejected.\n  Command: ${command.slice(0, 160)}`,
      };
    }

    for (const pattern of WHITELIST) {
      if (pattern.test(command)) return undefined;
    }

    return {
      block: true,
      reason:
        `Level 4 whitelist: command not in allowlist.\n  Command: ${command.slice(0, 160)}\n  ` +
        `Tip: only commands matching one of ${WHITELIST.length} curated patterns may run.`,
    };
  });
}
