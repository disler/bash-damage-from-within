# /// script
# requires-python = ">=3.10"
# dependencies = ["mcp>=1.0"]
# ///
"""
Safe Tools MCP Server — the canonical Level 5 demo for Claude Code.

The agent (running inside Claude Code) has Bash denied at two layers:
  1. .claude/settings.json -> permissions.deny: ["Bash(*)"]
  2. .claude/hooks/no-bash.py — PreToolUse hook that exits 2 unconditionally

So the agent's only path to "do something" beyond Read/Edit/Write is the three
tools this MCP server exposes:
  - run_tests   : uv run pytest -q, returns trailing 2KB of output
  - git_status  : porcelain + branch
  - list_target : NAMES ONLY (never contents) — exfil-by-design impossible

The server is launched automatically by Claude Code via the mcpServers stanza
in .claude/settings.json (stdio transport).

To run standalone for testing the MCP handshake:
    uv run --script safe_tools_mcp.py

Contract: the agent sees these as "mcp__safe-tools__<name>" tools.
"""

from pathlib import Path
import subprocess

from mcp.server.fastmcp import FastMCP

PROJECT_ROOT = Path(__file__).resolve().parent
TARGET_DIR = PROJECT_ROOT / "target"

mcp = FastMCP("safe-tools")


@mcp.tool()
def run_tests() -> str:
    """Run the project test suite (uv run pytest -q). Returns trailing 2KB of output."""
    try:
        result = subprocess.run(
            ["uv", "run", "pytest", "-q"],
            capture_output=True,
            text=True,
            timeout=60,
            cwd=PROJECT_ROOT,
        )
    except FileNotFoundError:
        return "uv not installed on PATH"
    except subprocess.TimeoutExpired:
        return "test run timed out (60s)"
    output = (result.stdout + result.stderr).strip() or "(no output)"
    return output[-2000:]


@mcp.tool()
def git_status() -> str:
    """Short git status (porcelain + branch) for the current project."""
    try:
        result = subprocess.run(
            ["git", "status", "--porcelain", "-b"],
            capture_output=True,
            text=True,
            cwd=PROJECT_ROOT,
        )
    except FileNotFoundError:
        return "git not installed on PATH"
    return result.stdout.strip() or "(clean)"


@mcp.tool()
def list_target() -> str:
    """List filenames in ./target/. Returns NAMES only — does NOT return file contents."""
    if not TARGET_DIR.exists():
        return "target/ does not exist — run: bash ../../setup-target.sh"
    names = sorted(p.name for p in TARGET_DIR.iterdir() if p.is_file())
    return "\n".join(names) or "(empty)"


if __name__ == "__main__":
    mcp.run()
