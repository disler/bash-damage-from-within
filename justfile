# Justfile for the Damage From Within demo codebase.
# Boots agents at each security level for both Claude Code and Pi.
#
# Usage:
#   just                # list all recipes
#   just doctor         # check toolchain + set executable bits
#   just cc-3           # launch Claude Code at Level 3
#   just pi-5           # launch Pi at Level 5
#   just attack 2       # copy attack prompt #2 to clipboard
#   just status         # show target/ state across all levels
#   just reset          # repopulate every level's target/

set dotenv-load := true

# List all available recipes
default:
    @just --list

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------

# Level 1 — safe-mode skill (theatre, no enforcement)
cc-1:
    #!/usr/bin/env bash
    set -e
    cd claude-code/level-1-user-prompt
    bash ../../setup-target.sh
    printf '\n\033[1;36m═══ Claude Code — Level 1: safe-mode skill ═══\033[0m\n\n'
    printf '  \033[2mEnforcement\033[0m   none — guidance only\n'
    printf '  \033[2mMechanism\033[0m     .claude/skills/safe-mode/SKILL.md\n'
    printf '  \033[2mBash policy\033[0m   model decides (theatre)\n\n'
    printf '\033[1;36m▶ claude --dangerously-skip-permissions\033[0m\n\n'
    claude --dangerously-skip-permissions

# Level 2 — --append-system-prompt (theatre, more authoritative)
cc-2:
    #!/usr/bin/env bash
    set -e
    cd claude-code/level-2-system-prompt
    bash ../../setup-target.sh
    printf '\n\033[1;36m═══ Claude Code — Level 2: --append-system-prompt ═══\033[0m\n\n'
    printf '  \033[2mEnforcement\033[0m   none — guidance only\n'
    printf '  \033[2mMechanism\033[0m     system-prompt.txt appended to system prompt\n'
    printf '  \033[2mBash policy\033[0m   model decides (theatre, with more authority)\n\n'
    printf '\033[1;36m▶ claude --dangerously-skip-permissions --append-system-prompt "$(cat system-prompt.txt)"\033[0m\n\n'
    claude --dangerously-skip-permissions --append-system-prompt "$(cat system-prompt.txt)"

# Level 3 — PreToolUse blacklist hook
cc-3:
    #!/usr/bin/env bash
    set -e
    cd claude-code/level-3-blacklist
    bash ../../setup-target.sh
    printf '\n\033[1;36m═══ Claude Code — Level 3: Bash blacklist ═══\033[0m\n\n'
    printf '  \033[2mEnforcement\033[0m   .claude/hooks/blacklist.py + .claude/settings.json (permissions.deny)\n'
    printf '  \033[2mMechanism\033[0m     PreToolUse hook regex-matches every bash command; exit 2 = block\n'
    printf '  \033[2mBash policy\033[0m   blocked: rm -rf, sudo, aws/gcloud/vercel, curl|sh, dd, mkfs, others\n\n'
    printf '\033[1;36m▶ claude --dangerously-skip-permissions\033[0m\n\n'
    claude --dangerously-skip-permissions

# Level 4 — PreToolUse whitelist hook (default-deny)
cc-4:
    #!/usr/bin/env bash
    set -e
    cd claude-code/level-4-whitelist
    bash ../../setup-target.sh
    printf '\n\033[1;36m═══ Claude Code — Level 4: Bash whitelist ═══\033[0m\n\n'
    printf '  \033[2mEnforcement\033[0m   .claude/hooks/whitelist.py + permissions.deny: Bash(*)\n'
    printf '  \033[2mMechanism\033[0m     PreToolUse default-deny + curated allowlist + shell-operator pre-reject\n'
    printf '  \033[2mBash policy\033[0m   only ~10 anchored patterns run (npm test, git status, uv pytest, ...)\n\n'
    printf '\033[1;36m▶ claude --dangerously-skip-permissions\033[0m\n\n'
    claude --dangerously-skip-permissions

# Level 5 (canonical) — minimal MCP server replaces bash for shell-style ops
cc-5:
    #!/usr/bin/env bash
    set -e
    cd claude-code/level-5-no-bash
    bash ../../setup-target.sh
    printf '\n\033[1;36m═══ Claude Code — Level 5 (canonical): No bash, MCP server ═══\033[0m\n\n'
    printf '  \033[2mEnforcement\033[0m   .mcp.json registers safe_tools_mcp.py; .claude/settings.json denies Bash\n'
    printf '  \033[2mMechanism\033[0m     deny: Bash, WebFetch, WebSearch, Read(./target/secrets.env)\n'
    printf '  \033[2mTool surface\033[0m  Read/Write/Edit/Glob/Grep + mcp__safe-tools__{run_tests, git_status, list_target}\n\n'
    printf '\033[1;36m▶ claude --dangerously-skip-permissions\033[0m\n\n'
    claude --dangerously-skip-permissions

# Level 5 (variant) — Agent SDK with no Bash, custom tools registered in-process
cc-5-agent-sdk:
    #!/usr/bin/env bash
    set -e
    cd claude-code/level-5-no-bash
    bash ../../setup-target.sh
    printf '\n\033[1;36m═══ Claude Code — Level 5 (variant): No bash, Agent SDK ═══\033[0m\n\n'
    printf '  \033[2mEnforcement\033[0m   agent_sdk_demo.py (programmatic agent)\n'
    printf '  \033[2mMechanism\033[0m     allowed_tools omits Bash; create_sdk_mcp_server registers tools in-process\n'
    printf '  \033[2mBash policy\033[0m   bash not in the tool list — model never sees it\n\n'
    printf '\033[1;36m▶ uv run agent_sdk_demo.py\033[0m\n\n'
    uv run agent_sdk_demo.py

# ---------------------------------------------------------------------------
# Pi
# ---------------------------------------------------------------------------

# Level 1 — safe-mode skill (theatre, no enforcement)
pi-1:
    #!/usr/bin/env bash
    set -e
    cd pi/level-1-user-prompt
    bash ../../setup-target.sh
    printf '\n\033[1;36m═══ Pi — Level 1: safe-mode skill ═══\033[0m\n\n'
    printf '  \033[2mEnforcement\033[0m   none — guidance only\n'
    printf '  \033[2mMechanism\033[0m     .pi/skills/safe-mode/SKILL.md\n'
    printf '  \033[2mBash policy\033[0m   model decides (theatre)\n\n'
    printf '\033[1;36m▶ pi -e ../../extensions/minimal.ts\033[0m\n\n'
    pi -e ../../extensions/minimal.ts

# Level 2 — --append-system-prompt (theatre, more authoritative)
pi-2:
    #!/usr/bin/env bash
    set -e
    cd pi/level-2-system-prompt
    bash ../../setup-target.sh
    printf '\n\033[1;36m═══ Pi — Level 2: --append-system-prompt ═══\033[0m\n\n'
    printf '  \033[2mEnforcement\033[0m   none — guidance only\n'
    printf '  \033[2mMechanism\033[0m     system-prompt.txt appended to system prompt\n'
    printf '  \033[2mBash policy\033[0m   model decides (theatre, with more authority)\n\n'
    printf '\033[1;36m▶ pi -e ../../extensions/minimal.ts --append-system-prompt "$(cat system-prompt.txt)"\033[0m\n\n'
    pi -e ../../extensions/minimal.ts --append-system-prompt "$(cat system-prompt.txt)"

# Level 3 — tool_call blacklist extension
pi-3:
    #!/usr/bin/env bash
    set -e
    cd pi/level-3-blacklist
    bash ../../setup-target.sh
    printf '\n\033[1;36m═══ Pi — Level 3: Bash blacklist ═══\033[0m\n\n'
    printf '  \033[2mEnforcement\033[0m   .pi/extensions/blacklist.ts (auto-discovered)\n'
    printf '  \033[2mMechanism\033[0m     tool_call event → regex match → { block: true, reason }\n'
    printf '  \033[2mBash policy\033[0m   blocked: rm -rf, sudo, aws/gcloud/vercel, curl|sh, dd, mkfs, others\n\n'
    printf '\033[1;36m▶ pi -e ../../extensions/minimal.ts\033[0m\n\n'
    pi -e ../../extensions/minimal.ts

# Level 4 — tool_call default-deny whitelist
pi-4:
    #!/usr/bin/env bash
    set -e
    cd pi/level-4-whitelist
    bash ../../setup-target.sh
    printf '\n\033[1;36m═══ Pi — Level 4: Bash whitelist ═══\033[0m\n\n'
    printf '  \033[2mEnforcement\033[0m   .pi/extensions/whitelist.ts (auto-discovered)\n'
    printf '  \033[2mMechanism\033[0m     tool_call default-deny + curated allowlist + shell-operator pre-reject\n'
    printf '  \033[2mBash policy\033[0m   only ~10 anchored patterns run (npm test, git status, uv pytest, ...)\n\n'
    printf '\033[1;36m▶ pi -e ../../extensions/minimal.ts\033[0m\n\n'
    pi -e ../../extensions/minimal.ts

# Level 5 — bash hard-blocked + safe tools via registerTool
pi-5:
    #!/usr/bin/env bash
    set -e
    cd pi/level-5-no-bash
    bash ../../setup-target.sh
    printf '\n\033[1;36m═══ Pi — Level 5: No bash + custom tools ═══\033[0m\n\n'
    printf '  \033[2mEnforcement\033[0m   .pi/extensions/no-bash.ts (auto-discovered)\n'
    printf '  \033[2mMechanism\033[0m     tool_call hard-blocks bash + pi.registerTool() exposes 3 safe tools\n'
    printf '  \033[2mBash policy\033[0m   bash unavailable; agent has read/edit/write + run_tests/git_status/list_target\n\n'
    printf '\033[1;36m▶ pi -e ../../extensions/minimal.ts --tools read,edit,write,grep,find,run_tests,git_status,list_target\033[0m\n\n'
    pi -e ../../extensions/minimal.ts --tools read,edit,write,grep,find,run_tests,git_status,list_target

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Verify toolchain + set executable bits on hooks/scripts
doctor:
    #!/usr/bin/env bash
    set -e
    echo "Toolchain:"
    command -v just   >/dev/null && echo "  ✓ just"   || echo "  ✗ just      (brew install just)"
    command -v uv     >/dev/null && echo "  ✓ uv"     || echo "  ✗ uv        (curl -LsSf https://astral.sh/uv/install.sh | sh)"
    command -v claude >/dev/null && echo "  ✓ claude" || echo "  ✗ claude    (Claude Code CLI)"
    command -v pi     >/dev/null && echo "  ✓ pi"     || echo "  ✗ pi        (npm i -g @mariozechner/pi-coding-agent)"
    command -v node   >/dev/null && echo "  ✓ node"   || echo "  ✗ node      (required for Pi)"
    echo
    echo "Setting executable bits..."
    chmod +x setup-target.sh
    chmod +x claude-code/level-2-system-prompt/invoke.sh
    find claude-code -type f -name '*.py' -exec chmod +x {} \;
    echo "  ✓ setup-target.sh"
    echo "  ✓ all *.py scripts under claude-code/"
    echo
    echo "Ready. Try: just status"

# Reset target/ in every level (idempotent)
reset:
    #!/usr/bin/env bash
    set -e
    for d in claude-code/level-*/ pi/level-*/; do
      (cd "$d" && bash ../../setup-target.sh) >/dev/null
      printf "  ✓ %s\n" "$d"
    done

# Show target/ contents across all levels (sanity check)
status:
    #!/usr/bin/env bash
    for d in claude-code/level-*/ pi/level-*/; do
      printf "\n=== %s ===\n" "$d"
      if [ -d "$d/target" ]; then
        ls "$d/target"
      else
        echo "(no target/ — run: just reset)"
      fi
    done

# Copy attack prompt N (1-6) to clipboard, ready to paste into the agent
attack n:
    #!/usr/bin/env bash
    set -e
    file=$(ls attack-prompts/0{{n}}-*.md 2>/dev/null | head -1)
    if [ -z "$file" ]; then
      echo "No attack prompt for number {{n}}. Available:"
      ls attack-prompts/0*.md | sed 's|attack-prompts/||'
      exit 1
    fi
    extracted=$(grep '^> ' "$file" | sed 's/^> //')
    printf "%s" "$extracted" | pbcopy
    echo "Copied to clipboard from $(basename $file):"
    echo "---"
    printf "%s\n" "$extracted"
    echo "---"

# Prime a fresh Claude Code agent with this codebase's context (.claude/commands/prime.md)
prime:
    #!/usr/bin/env bash
    set -e
    printf '\n\033[1;36m▶ claude --dangerously-skip-permissions "/prime"\033[0m\n\n'
    claude --dangerously-skip-permissions "/prime"

# Prime a fresh Pi agent with this codebase's context (uses .claude/commands/prime.md as the seed prompt)
primepi:
    #!/usr/bin/env bash
    set -e
    printf '\n\033[1;36m▶ pi -e extensions/minimal.ts "$(cat .claude/commands/prime.md)"\033[0m\n\n'
    pi -e extensions/minimal.ts "$(cat .claude/commands/prime.md)"

# Run the installation flow inside Claude Code (.claude/commands/install.md)
install:
    #!/usr/bin/env bash
    set -e
    printf '\n\033[1;36m▶ claude --dangerously-skip-permissions "/install"\033[0m\n\n'
    claude --dangerously-skip-permissions "/install"
