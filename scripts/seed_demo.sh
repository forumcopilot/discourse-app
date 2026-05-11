#!/usr/bin/env bash
# Convenience wrapper around seed_discourse_demo.rb.
#
# Assumes:
#   - The Discourse install lives at $DISCOURSE_DIR (default
#     /Volumes/CRUCIAL/discourse).
#   - You have run `bin/dev` / migrations at least once so Postgres is
#     populated.
#
# Usage:
#   ./scripts/seed_demo.sh
#   DISCOURSE_DIR=/path/to/discourse ./scripts/seed_demo.sh

set -euo pipefail

DISCOURSE_DIR="${DISCOURSE_DIR:-/Volumes/CRUCIAL/discourse}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_SCRIPT="${SCRIPT_DIR}/seed_discourse_demo.rb"

if [[ ! -d "$DISCOURSE_DIR" ]]; then
  echo "✗ Discourse install not found at $DISCOURSE_DIR"
  echo "  Set DISCOURSE_DIR to override."
  exit 1
fi

if [[ ! -f "$SEED_SCRIPT" ]]; then
  echo "✗ Seed script not found: $SEED_SCRIPT"
  exit 1
fi

cd "$DISCOURSE_DIR"

# Wire up rbenv if the Discourse install pins a Ruby version via
# .ruby-version. System Ruby on macOS is 2.6 which Discourse can't
# boot — without this, bundler errors out before the runner starts.
if [[ -f "$DISCOURSE_DIR/.ruby-version" ]] && command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - bash 2>/dev/null)" || true
  RUBY_VERSION="$(cat "$DISCOURSE_DIR/.ruby-version" | tr -d '[:space:]')"
  rbenv shell "$RUBY_VERSION" 2>/dev/null || true
  echo "→ using Ruby $(ruby -v)"
fi

echo "→ running seed against $DISCOURSE_DIR"
exec bin/rails runner "$SEED_SCRIPT"
