#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""
Trimmed v6 status line — model name + context bar + N%.

Reads the status JSON from stdin, prints a single line like:

    [Opus 4.7] [#####----------] 23.4%

Bar color shifts green → yellow → red as the context fills.
"""

import json
import sys


# ANSI
CYAN = "\033[36m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
BRIGHT_RED = "\033[91m"
DIM = "\033[90m"
RESET = "\033[0m"


def usage_color(pct: float) -> str:
    if pct < 50:
        return GREEN
    if pct < 75:
        return YELLOW
    if pct < 90:
        return RED
    return BRIGHT_RED


def progress_bar(pct: float, width: int = 15) -> str:
    filled = int((pct / 100) * width)
    empty = width - filled
    color = usage_color(pct)
    return f"[{color}{'#' * filled}{DIM}{'-' * empty}{RESET}]"


def main() -> None:
    try:
        data = json.loads(sys.stdin.read())
    except json.JSONDecodeError:
        print(f"{RED}[Claude] [---------------] --%{RESET}")
        return

    model = data.get("model", {}).get("display_name", "Claude")
    pct = (data.get("context_window") or {}).get("used_percentage") or 0.0

    color = usage_color(pct)
    print(f"{CYAN}[{model}]{RESET} {progress_bar(pct)} {color}{pct:.1f}%{RESET}")


if __name__ == "__main__":
    main()
