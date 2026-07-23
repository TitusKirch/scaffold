#!/usr/bin/env bash
#
# Switches this repo from the `dev` integration branch to a main-only workflow:
# copies `template/` over the repo root and drops the dev-only workflow.
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

# The main-only variant also *removes* a file, which copying alone cannot do.
echo "Removing:"
echo "  .github/workflows/dev-pr.yml"
rm -f .github/workflows/dev-pr.yml

cat <<'EOF'

Done. Remaining steps:
  1. delete the `dev` branch if it already exists
  2. rm -rf template apply-template.sh
EOF
