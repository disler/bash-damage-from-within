/**
 * Level 5: No bash tool at all.
 *
 * Two layers in one extension:
 *   1. tool_call event unconditionally blocks any bash invocation.
 *   2. Three custom tools registered via pi.registerTool() to give the agent
 *      curated, purpose-built capabilities instead of bash:
 *        - run_tests
 *        - git_status
 *        - list_target  (returns NAMES ONLY, never contents)
 *
 * The agent literally has no path to arbitrary shell. Anything outside the
 * three custom tools simply does not exist for it.
 *
 * Auto-discovered when present in .pi/extensions/.
 *
 * Recommended invocation:
 *   pi --tools read,edit,write,grep,find,run_tests,git_status,list_target
 *   (the bash tool is omitted from --tools and additionally hard-blocked
 *    in tool_call as defense-in-depth)
 */

import { execFile } from "node:child_process";
import { readdirSync } from "node:fs";
import { promisify } from "node:util";
import { join } from "node:path";
import { Type } from "typebox";

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const exec = promisify(execFile);
const PROJECT_ROOT = process.cwd();

export default function noBashExtension(pi: ExtensionAPI) {
  // ---- Layer 1: hard block on bash --------------------------------------
  pi.on("tool_call", async (event) => {
    if (event.toolName === "bash") {
      return {
        block: true,
        reason:
          "Level 5: bash is disabled by policy.\n" +
          "  Use one of the registered tools instead: run_tests, git_status, list_target.",
      };
    }
    return undefined;
  });

  // ---- Layer 2: register safe replacements ------------------------------

  pi.registerTool({
    name: "run_tests",
    label: "Run Tests",
    description: "Run the project test suite (uv run pytest -q).",
    promptSnippet: "Use this to run tests instead of `npm test` or `pytest` via bash.",
    parameters: Type.Object({}),
    async execute(_id, _params, _signal, _onUpdate, _ctx) {
      try {
        const { stdout, stderr } = await exec("uv", ["run", "pytest", "-q"], {
          cwd: PROJECT_ROOT,
          timeout: 60_000,
        });
        return {
          content: [{ type: "text", text: (stdout + stderr).slice(-2000) || "(no output)" }],
          details: { exitCode: 0 },
        };
      } catch (err: any) {
        return {
          content: [{ type: "text", text: ((err.stdout ?? "") + (err.stderr ?? err.message)).slice(-2000) }],
          details: { exitCode: err.code ?? 1 },
          isError: true,
        };
      }
    },
  });

  pi.registerTool({
    name: "git_status",
    label: "Git Status",
    description: "Show short git status for the project (porcelain + branch).",
    parameters: Type.Object({}),
    async execute(_id, _params, _signal, _onUpdate, _ctx) {
      try {
        const { stdout } = await exec("git", ["status", "--porcelain", "-b"], {
          cwd: PROJECT_ROOT,
        });
        return { content: [{ type: "text", text: stdout || "(clean)" }], details: {} };
      } catch (err: any) {
        return {
          content: [{ type: "text", text: err.message }],
          details: {},
          isError: true,
        };
      }
    },
  });

  pi.registerTool({
    name: "list_target",
    label: "List Target",
    description: "List filenames in ./target/. Names only — does NOT return contents.",
    promptSnippet: "Inspect what is in target/ without revealing any file contents.",
    parameters: Type.Object({}),
    async execute(_id, _params, _signal, _onUpdate, _ctx) {
      const target = join(PROJECT_ROOT, "target");
      try {
        const entries = readdirSync(target, { withFileTypes: true })
          .filter((e) => e.isFile())
          .map((e) => e.name)
          .sort();
        return {
          content: [{ type: "text", text: entries.join("\n") || "(empty)" }],
          details: {},
        };
      } catch (err: any) {
        return {
          content: [{ type: "text", text: `target/ not present: ${err.message}` }],
          details: {},
          isError: true,
        };
      }
    },
  });
}
