#!/usr/bin/env bash
# Run from the root of your Rust project. Never overwrites existing files.
set -euo pipefail

REPO="Hannoah/agentic-rust-starter"
BRANCH="main"
FILES=(CONVENTIONS.md .aider.conf.yml ai-verify.sh clippy.toml Cargo.toml docs/ai_context/crate_cheatsheet.md)

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$tmp" --strip-components=1

for f in "${FILES[@]}"; do
  if [ -e "$f" ]; then
    echo "skip (already exists): $f"
  else
    mkdir -p "$(dirname "$f")"
    cp "$tmp/$f" "$f"
    echo "added: $f"
  fi
done
chmod +x ai-verify.sh

if [ -f Cargo.toml ] && ! grep -q '^\[lints' Cargo.toml; then
  echo
  echo "NOTE: your Cargo.toml has no [lints] section. Merge the [lints.rust] / [lints.clippy]"
  echo "blocks from https://github.com/$REPO#기존-프로젝트에-적용"
fi
echo "Done. Start with: aider"
