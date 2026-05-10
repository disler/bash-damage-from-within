/**
 * Level 3: Bash blacklist — Pi tool_call extension.
 *
 * Blocks the model from executing dangerous bash commands by intercepting
 * the tool_call event and returning { block: true } when the command
 * matches a regex blacklist.
 *
 * Auto-discovered when present in .pi/extensions/.
 *
 * Verified against examples/extensions/permission-gate.ts shipped with
 * @mariozechner/pi-coding-agent 0.70.6.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const BLACKLIST: Array<{ pattern: RegExp; label: string }> = [
  { pattern: /\brm\s+(-[rRf]+|--recursive|--force)\b/i, label: "rm with recursive/force flags" },
  { pattern: /\brm\s+\//i, label: "rm targeting root paths" },
  { pattern: /\bsudo\b/i, label: "sudo escalation" },
  { pattern: /\bchmod\s+(-R\s+)?[0-7]*7[0-7]{2}\b/i, label: "world-writable chmod" },
  { pattern: /\b(aws|gcloud|vercel)\s+/i, label: "cloud CLI" },
  { pattern: /\bcurl\s+.*\|\s*(sh|bash|zsh)\b/i, label: "curl piped to shell" },
  { pattern: /\bgit\s+reset\s+--hard\b/i, label: "git destructive reset" },
  { pattern: /\bgit\s+push\s+(-f|--force)(?!-with-lease)\b/i, label: "git force-push without lease" },
  { pattern: /\bdd\s+if=.*of=\/dev\//i, label: "dd to device" },
  { pattern: /\bmkfs\./i, label: "mkfs" },
  { pattern: /target\/secrets\.env\b/i, label: "secrets.env access via bash" },
];

export default function blacklistExtension(pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash") return undefined;

    const command = (event.input?.command as string) ?? "";

    for (const { pattern, label } of BLACKLIST) {
      if (pattern.test(command)) {
        const preview = command.length > 160 ? `${command.slice(0, 160)}...` : command;
        return {
          block: true,
          reason: `Level 3 blacklist: ${label}\n  Command: ${preview}`,
        };
      }
    }

    return undefined;
  });
}
