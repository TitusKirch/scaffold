# scaffold

A **GitHub template repository**: the meta layer (lint, format, hooks, CI, CodeQL, Dependabot, release-please, issue/PR templates, meta docs) every new kirchDev repo starts with. There is no application code, and downstream code can be any stack — so every default must make sense for _every_ repo created from it, not one project type.

Why each default is set the way it is — the reasoning these rules leave out — is in `docs/1.concepts/`.

## Commands

`pnpm check` is the gate (`lint` + `format` + `typecheck` + `check:policy`); CI runs the same script. There is no test suite. `pnpm format` only checks — fix with `pnpm format:fix` or `pnpm check:fix`. Every script: `package.json`.

## Conventions

- **Node 24, pnpm 12**, pinned in `.nvmrc`, `engines` and `packageManager`. Keep `minimumReleaseAge: 4320` and `nodeLinker: isolated` in `pnpm-workspace.yaml`; leave `pmOnFail` unset (reason in the file).
- **oxc, not eslint/prettier** — `.oxlintrc.json`, `.oxfmtrc.json`, rules deliberately minimal.
- **TypeScript without a build step.** `scripts/check-policy-parity.ts` and the three `*.config.ts` run on Node's type stripping. `tsconfig.json` sets `erasableSyntaxOnly`: no enums, no parameter properties. A non-JS downstream repo drops `tsconfig.json`, the `typecheck` script and the types.
- **Hooks:** Husky runs `lint-staged` on pre-commit and `commitlint` on commit-msg. `README.md` and `AGENTS.md` are free-form prose and stay out of `oxfmt`.
- **Conventional Commits** via `@commitlint/config-conventional`. Never `--no-verify` unless asked.
- **release-please** (`release-please-config.json`, `.release-please-manifest.json`, `release-please.yml`): `release-type: node`, `v`-prefixed tags. Downstream repos reset to `0.0.0` per README → _Resetting release-please_.
- **Dependabot:** one grouped minor/patch PR per ecosystem, majors separate, 3-day cooldown. The security-update blocks in `.github/dependabot.yml` must never get `target-branch` (reason in the file).

## Workflows are calls, not copies

Every `.github/workflows/*.yml` is a stub calling a body in [`kirchDev/workflows`](https://github.com/kirchDev/workflows), pinned to a commit SHA with the version as a trailing comment; Dependabot raises the bumps.

- **Never paste a body back in.** A stub that almost fits needs an input on the body or an own job beside the call — see `docs/1.guides/2.add-a-body.md` there.
- A repo that publishes adds its own job to `release-please.yml`, gated on `needs.release-please.outputs.release-created`.
- A compiled language goes into `codeql.yml`'s `languages` input, not a forked workflow.
- `ci.yml` runs the `check` script, so a new check needs no workflow change.

## Branching model

`dev` is the integration branch: branch off and PR into `dev`; the promotion PR (`promotion-pr.yml`) rolls `dev` into `stage` if that branch exists, else into `main`; release-please releases from `main`.

> [!IMPORTANT]
> A repo created from this template has the `dev` config but **no `dev` branch**. Create it before the first Dependabot run — with `target-branch: 'dev'` pointing nowhere, Dependabot opens nothing.

- Merge the promotion PR with a **merge commit, never a squash** — a squash collapses the `feat:`/`fix:` commits into one `chore:` and release-please cuts nothing.
- **Main-only** is three removals: delete `promotion-pr.yml`, drop both `target-branch: 'dev'` lines from `.github/dependabot.yml`, set `pr.base` to `"main"` in `.tituskirch-skills.json`. Leave `dev` in the `ci.yml`/`codeql.yml` branch filters: a missing branch is a no-op, and without it PRs into `dev` get no CI.
- A variant that only deletes stays documented here, never vendored as files.

## Public vs private repos

- **CodeQL** needs GitHub Advanced Security, free only on public repos. A private repo without GHAS deletes `codeql.yml` (likewise other GHAS-gated features).
- **License:** public ships MIT (`LICENSE` + README footer). Private removes both and sets `"license": "UNLICENSED"` and `"private": true` in `package.json`.
- **Discord:** `.github/ISSUE_TEMPLATE/config.yml` routes questions, ideas and possible bugs to the repo's Discord forum. A private repo has none — drop `contact_links`, optionally add a `question.yml`.

## Agent setup

- `.tituskirch-skills.json` configures the [TitusKirch skills](https://github.com/TitusKirch/skills); change it through the `tituskirch-skills-config` skill.
- The skills are installed with `pnpm dlx skills add TitusKirch/skills`, never vendored. `pnpm skills:update` refreshes the project-scoped ones in `skills-lock.json`.
- `.claude/settings.local.json` holds per-machine overrides and is gitignored.

## Permission policy

`.claude/settings.json` and `.codex/rules/default.rules` carry the same block list and **change together**. `pnpm check:policy` proves parity in both directions; test a single Codex rule with `codex execpolicy check --pretty --rules .codex/rules/default.rules -- <command>`.

- **`deny` may be generous** and covers every stack kirchDev repos might grow into. It holds only what a mistaken "yes" cannot undo: wrecking the machine (`dd`, `mkfs`, `chmod -R`, `rm -rf /…`), tearing down remote state (`terraform destroy`, `gh repo delete`, …), or losing work without recovery (force-push, `reset --hard`, `stash drop`, `reflog expire`, `gc --prune=now`). Ordinary local development — `rm -rf node_modules`, `docker compose down -v`, `php artisan tinker`, deleting a remote branch — prompts instead.
- **`allow` stays short:** only what runs many times per session — read-only git, `git push`, `ls`/`grep`/`rg`, the project's check scripts. Everything else prompts.
- A gap the two rule languages force (string prefix vs. argv tokens, e.g. `Bash(aws iam delete-:*)`) must be declared in `DELIBERATE` in `scripts/check-policy-parity.ts` and in the rules header; the check fails on an undeclared and on a stale declaration.
- Parity covers the same **spellings**, not completeness: neither file normalises flag order or case, sees flags before a subcommand (`docker compose -f x.yml down -v`), or knows which branch a push targets — protect release branches with branch protection.
- Downstream repos keep `deny` as-is and swap the `pnpm` lines in `allow` for their stack.

> [!IMPORTANT]
> **Never allow a rule that runs arbitrary code** — `php artisan tinker --execute`, `pnpm exec turbo run`, `find . *`, a raw `pnpm dlx`, an SQL-executing MCP tool. One such rule voids the whole `deny` list.

## Editing the template

- Every `TitusKirch/scaffold` reference is a placeholder; keep them catchable by one `grep -rn "TitusKirch/scaffold"`.
- READMEs and meta files follow `/write-readme`: centered hero, prescribed section emojis, the fixed MIT footer, GitHub callouts instead of plain blockquotes.
- When a config choice is unclear, check `../forgemap`, the reference implementation.
