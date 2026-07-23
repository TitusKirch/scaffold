#!/usr/bin/env bash
#
# Copies `template/` over the repo root, replacing the files it shadows, to
# switch this repo onto a `dev` integration branch.
# See CLAUDE.md → Branching model.

set -euo pipefail

cd "$(dirname "$0")"

if [ ! -d template ]; then
  echo "apply-template: no template/ directory here — nothing to apply." >&2
  exit 1
fi

echo "Copying template/ over the repo root:"
find template -type f | sed 's|^template/|  |' | sort

# The trailing dot matters: `template/*` would silently skip the dotfiles,
# which is every file that actually needs replacing here.
cp -a template/. .

cat <<'EOF'

Done. Remaining steps:
  1. create the `dev` branch and push it
  2. keep `main` as the repository's default branch
  3. rm -rf template apply-template.sh
EOF
