#!/usr/bin/env bash
# Populate ./target/ in the current directory from target-template/.
# Run from any level directory before launching the agent.
#
# Usage:
#   bash ../../setup-target.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/target-template"

if [ ! -d "$TEMPLATE" ]; then
  echo "Error: target-template not found at $TEMPLATE" >&2
  exit 1
fi

# Refuse to operate outside the demo tree
if [[ "$PWD" != *"bash-damage-from-within"* ]]; then
  echo "Refusing to populate target/ outside the demo tree (pwd=$PWD)" >&2
  exit 1
fi

if [ -d "./target" ]; then
  rm -rf ./target
fi
cp -R "$TEMPLATE" ./target
# echo "Fresh target/ populated from $TEMPLATE"
# ls ./target
