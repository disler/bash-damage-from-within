---
description: Prime the agent with full context for the Damage From Within bash-security demo — five levels, two harnesses, runnable side-by-side.
---

# Purpose

This codebase pairs every bash-security level (1 → 5) with parallel Claude Code and Pi implementations so they can be cut side-by-side on camera. Priming means understanding the five-level ladder, the two harness implementations, the shared target/attack-prompts assets, and the `just` launch surface.

## Workflow

1. List the tree: `git ls-files 2>/dev/null || find . -type f -not -path '*/target/*' -not -path '*/.git/*' | sort`
2. Read the top-level orientation: `README.md`, plus (if present) `deep_docs/5_LEVELS_OF_BASH_SECURITY.md` and `deep_docs/DEMO_RUNBOOK.md` (these are gitignored working notes — skip if absent)
3. Read `justfile` to map recipes (`cc-1..cc-5`, `cc-5-agent-sdk`, `pi-1..pi-5`, helpers) to each level's directory
4. Skim the per-harness READMEs: `claude-code/README.md` and `pi/README.md`
5. Skim each level's README under `claude-code/level-*/README.md` and `pi/level-*/README.md`
6. Read the attack catalog: `attack-prompts/README.md` and the six numbered attack files
7. Summarize: the five-level ladder, the Claude Code ↔ Pi parallel, where each level's config lives, the shared `target-template/` and `attack-prompts/` assets, and which `just <recipe>` boots which demo
