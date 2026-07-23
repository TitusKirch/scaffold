# CLAUDE.md

This file provides guidance to AI coding agents — Claude Code (claude.ai/code) and vendor-neutral tools such as Codex, OpenCode, Cursor, and Copilot — when working with code in this repository.

## Agent instruction files

`CLAUDE.md` and `AGENTS.md` are **kept byte-identical**. `CLAUDE.md` is what Claude Code reads; `AGENTS.md` is what vendor-neutral agent tools (Codex, OpenCode, Cursor, Copilot, …) read. They are not pointers to each other — they carry the same content. **When you change one, make the exact same change to the other** so the two never drift.

## What this repo is

`scaffold` is a **GitHub template repository**, not an application. It ships the meta layer (lint, format, commit hooks, CI, CodeQL, Dependabot, release-please, issue/PR templates, standard meta docs) that every new kirchDev repo should start with. There is no application code — the project code can be anything (PHP, Go, Rust, Vue, shell). Only the meta layer lives here.

Implication: when changing files, ask "does this default make sense for _every_ future repo created from this template?" — not just for one project type.

## Commands

| Command             | What it does                                               |
| :------------------ | :--------------------------------------------------------- |
| `pnpm install`      | Install deps and wire husky hooks via the `prepare` script |
| `pnpm lint`         | `oxlint . --deny-warnings`                                 |
| `pnpm format`       | `oxfmt --check .` (note: `format` is the check, not fix)   |
| `pnpm check`        | Runs `lint` + `format` — the CI gate                       |
| `pnpm lint:fix`     | Auto-fix lint                                              |
| `pnpm format:fix`   | Auto-fix format                                            |
| `pnpm check:fix`    | Auto-fix lint + format                                     |
| `pnpm skills:update`| Update project-scoped agent skills via the skills.sh CLI   |
| `pnpm taze`         | Interactive dependency upgrade check                       |
| `pnpm taze:w`       | Write upgrade results                                      |

There is no test suite — this is config-only. CI runs `pnpm lint` and `pnpm format` on PR.

## Architecture / conventions

- **Node 24, pnpm 11.** Pinned via `.nvmrc`, `engines`, and `packageManager`. `pnpm-workspace.yaml` enforces `minimumReleaseAge=4320` (3-day cooldown), isolated node-linker. Don't loosen these without reason.
- **oxc, not eslint/prettier.** Linting via `oxlint`, formatting via `oxfmt`. Configs live in `.oxlintrc.json` / `.oxfmtrc.json`. `oxlint` uses `unicorn` + `oxc` plugins; rules deliberately minimal.
- **Husky hooks** (`.husky/pre-commit`, `.husky/commit-msg`) run `lint-staged` and `commitlint`. `lint-staged.config.js` excludes `README.md`, `CLAUDE.md`, and `AGENTS.md` (free-form prose) and `pnpm-lock.yaml`. `oxlint --fix --deny-warnings` then `oxfmt` on JS; `oxfmt` only on JSON/YAML/MD.
- **Conventional Commits enforced** via `@commitlint/config-conventional`. Don't `--no-verify` unless explicitly asked.
- **release-please is included** (unlike many templates that omit it). Files: `release-please-config.json`, `.release-please-manifest.json`, `.github/workflows/release-please.yml`. Config uses `release-type: simple` (language-agnostic), `include-v-in-tag: true`. Downstream repos start at `0.0.0` and reset via the steps in README → _Resetting release-please_.
- **Workflows** use `actions/checkout@v6`, `actions/setup-node@v6`, `pnpm/action-setup@v6`, `github/codeql-action/{init,analyze}@v4`. Keep these pinned to major versions; Dependabot bumps them monthly.
- **CodeQL** scans `actions` + `javascript-typescript` with `security-extended,security-and-quality` queries, gated by path filters so non-code changes don't trigger it.
- **Dependabot** groups all minor/patch updates per ecosystem into a single PR (`npm-minor-patch`, `actions-minor-patch`). Majors come as separate PRs.

## AI & skills

- **`.claude/settings.json`** ships a baseline permission policy: read-only git and the `pnpm` scripts are allowed; destructive git (`push`, `reset --hard`, `clean -f`, `checkout --`, `branch -D`) is denied. `.claude/settings.local.json` (per-machine overrides) is gitignored.
- **`.tituskirch-skills.json`** configures the [TitusKirch skills](https://github.com/TitusKirch/skills) (commit, PR, issue, release, docs …) per repo. It is the runtime **config**, not an installer. Regenerate/reconcile it with the `tituskirch-skills-config` skill.
- **Installing the skills.** The bundle is installed via the skills.sh CLI (`pnpm dlx skills add TitusKirch/skills`), not vendored into the repo. `pnpm skills:update` refreshes project-scoped skills tracked in `skills-lock.json` (only present once a repo actually installs project skills).

## Branching model

The default here is a **`dev` integration branch**: branch off `dev`, PR into `dev`, roll `dev` up into `main`, and release-please releases from `main`. That is what most kirchDev repos run, so the template runs it too — a variant that ships switched off is a variant nobody notices is broken.

> [!IMPORTANT]
> A repo created from this template has the `dev` config but **no `dev` branch**. Create it before the first Dependabot run: with `target-branch: 'dev'` pointing at a branch that doesn't exist, Dependabot opens nothing at all. Going main-only (below) is a deliberate step too — leaving the config untouched is the one option that silently does nothing.

`.github/workflows/dev-pr.yml` opens and updates the rolling draft `dev` → `main` PR. Mark that PR ready and **merge it with a merge commit, never a squash**: squashing collapses the individual `feat:`/`fix:` commits into the PR's own `chore:` title, and release-please then cuts nothing.

Going **main-only** is three edits, all of them removals:

```bash
rm .github/workflows/dev-pr.yml
# .github/dependabot.yml    — drop both `target-branch: 'dev'` lines
# .tituskirch-skills.json   — set `pr.base` to "main"
```

Nothing is vendored for this. A variant worth shipping as files is one that *adds* something — content that would otherwise be lost, the way `dev-pr.yml` itself would be. A variant that only deletes has nothing to preserve, so it stays documented, exactly like _Public vs private repos_ below.

`ci.yml` and `codeql.yml` list both `main` and `dev` in their `on: branches:` filters and neither edit touches them. A filter naming a branch that doesn't exist is a no-op, so it costs a main-only repo nothing — and without `dev` in `ci.yml`, PRs into `dev` (Dependabot's included) would run no CI at all.

Variants that are *purely* deletions — see _Public vs private repos_ below — stay documented rather than vendored; only this one earns the folder.

## Public vs private repos

Some meta defaults only make sense for one visibility. When spinning up a repo from this template, adjust for its visibility:

- **CodeQL / code scanning** (`.github/workflows/codeql.yml`) depends on GitHub Advanced Security. It's free on **public** repos; on a **private** repo without a GHAS license it won't run — delete `codeql.yml` (and the CodeQL note above) rather than leave a dead workflow. The same goes for other GHAS-gated features (secret scanning, etc.). Dependabot version updates work on both.
- **License.** A **public** repo ships MIT: keep `LICENSE` and the `[MIT](LICENSE) © …` README footer. A **private** repo is proprietary: remove/replace `LICENSE`, drop the MIT footer, and set `package.json` to `"license": "UNLICENSED"` (keep `"private": true`).

## House style for READMEs and meta files

`/write-readme` skill encodes the canonical structure. Key rules: hero block wrapped in `<div align="center">`, prescribed section emojis (✨ Features, 🚀 Setup, 🤝 Contributing, 🛣️ Versioning, 📄 License), license footer always reads `[MIT](LICENSE) © [Titus Kirch](https://github.com/TitusKirch/) / [IT-Dienstleistungen Titus Kirch](https://kirch.dev)`. Use GitHub callouts (`> [!TIP]`, `> [!IMPORTANT]`), never plain blockquotes.

## When editing this template

- Every file referencing `TitusKirch/scaffold` is a placeholder that downstream users will replace. Keep the references consistent so a single `grep -rn "TitusKirch/scaffold"` catches them all.
- `forgemap` (sibling repo at `../forgemap`) is the de-facto reference implementation of these conventions. When unsure about a config choice, check what forgemap does.
- The template's own `package.json` is `"private": true` and `"name": "scaffold"` — not published anywhere.
