<div align="center">

# 🏗️ scaffold

**The kirchDev baseline — everything a new repo should ship with on day one, nothing more**

</div>

---

```bash
gh repo create my-new-repo --template TitusKirch/scaffold
```

That's it. Click **Use this template** (or use `gh`), edit a handful of placeholders, and the meta layer — lint, format, commit hooks, CI, CodeQL, Dependabot, release-please — is already wired up.

## 🚀 Setup

After clicking **Use this template**:

1. Clone your new repo.
2. Replace the placeholders listed in [Customising the template](#-customising-the-template).
3. Reset release-please as described in [Resetting release-please](#-resetting-release-please).
4. `pnpm install` — Husky activates the hooks via the `prepare` script.
5. Add your project code and ship the first commit:

   ```bash
   git commit -m "chore: initial commit from scaffold"
   ```

## ✨ What's in the box

- **🟢 Node + pnpm pinned** — `.nvmrc` (Node 24), `pnpm-workspace.yaml` (pnpm 12 with sane defaults), `package.json` with `packageManager`.
- **🧹 Lint & format via oxc** — `.oxlintrc.json`, `.oxfmtrc.json`, single `pnpm check` gate.
- **🔷 TypeScript, no build step** — meta scripts and tool configs are `.ts`, run straight off Node 24's native type stripping; `tsconfig.json` + `pnpm typecheck`.
- **🪝 Commit hooks** — Husky + `lint-staged` + `commitlint` enforcing Conventional Commits.
- **🤖 Dependency PRs** — Dependabot (npm weekly, actions monthly) + `taze.config.ts` for interactive upgrades.
- **🔁 release-please** — full workflow + config + manifest so the new repo can publish from its first commit.
- **🛡️ GitHub workflows as calls** — six stubs pointing at central bodies in [`kirchDev/workflows`](https://github.com/kirchDev/workflows): CI, CodeQL, release-please, the promotion PR and the two queue workflows. 164 lines of trigger instead of a copied pipeline, and a central fix arrives by Dependabot bump.
- **📋 Issue / PR templates** — bug report and feature request (`.yml` forms), questions routed to Discord, plus a PR checklist.
- **📄 Standard meta** — `LICENSE`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`.
- **🤖 Agent-ready** — `AGENTS.md`, `.tituskirch-skills.json`, baseline `.claude/settings.json` permissions, `pnpm skills:update` wiring.

The actual project code can be anything — PHP, Go, Rust, Vue, plain shell. `scaffold` only owns the meta layer that sits on top.

## 🤖 AI & skills

Every repo from this template is agent-ready on day one:

- **`AGENTS.md`** — one set of guidance for Claude Code and vendor-neutral agent tools (Codex, OpenCode, Cursor, Copilot). Claude Code reads it only while no `CLAUDE.md` sits beside or above it.
- **`.claude/settings.json`** — baseline permissions: read-only git, `git push` and the `pnpm` check scripts are allowed; destructive git (force-push, `reset --hard`, `clean -f`, …) is denied.
- **`.tituskirch-skills.json`** — configures the [TitusKirch skills](https://github.com/TitusKirch/skills) (commit, PR, issue, release, docs) per repo.

Install the skill bundle, then keep project-scoped skills fresh:

```bash
pnpm dlx skills add TitusKirch/skills   # add the bundle — npx / yarn dlx / bunx work too
pnpm skills:update                       # refresh project-scoped skills
```

## 🧰 Customising the template

Every file below references `TitusKirch/scaffold`, the maintainer's name, or the maintainer's email. Search-and-replace these to your repo's identity before the first push.

| File                                  | Replace                                                                          |
| :------------------------------------ | :------------------------------------------------------------------------------- |
| `package.json`                        | `name`, `description`, `homepage`, `bugs.url`, `repository.url`, `author`        |
| `README.md`                           | Project title, tagline, hook snippet, every `TitusKirch/scaffold` link           |
| `LICENSE`                             | Copyright year + holder                                                          |
| `CODE_OF_CONDUCT.md`                  | Enforcement contact email                                                        |
| `CONTRIBUTING.md`                     | Every `TitusKirch/scaffold` link, the development setup section                  |
| `SECURITY.md`                         | Advisory URL, contact email, scope wording                                       |
| `.github/ISSUE_TEMPLATE/*.yml`        | Generic as shipped. `config.yml` links questions/ideas/possible-bugs to the Discord forum — private repos without a forum drop that block; optionally add stack-specific version fields to `bug_report.yml` |
| `.github/pull_request_template.md`    | Example commit message in the title hint                                         |
| `release-please-config.json`          | `packages["."]["package-name"]`                                                  |
| `AGENTS.md`                           | **Rewrite** for the new repo — scaffold-specific. Keep the name: a `CLAUDE.md` beside it stops Claude Code from reading it |

> [!TIP]
> A quick `grep -rn "TitusKirch/scaffold" .` catches every reference in one sweep.

> [!IMPORTANT]
> **Private repo?** Three defaults are public-only. Delete `.github/workflows/codeql.yml` (CodeQL needs GitHub Advanced Security — free only on public repos), swap the MIT `LICENSE` + README footer for a proprietary notice with `package.json` `"license": "UNLICENSED"`, and drop the Discord `contact_links` block from `.github/ISSUE_TEMPLATE/config.yml`. Note too that the workflow bodies live in a **public** repository — a private repo can still call them, but the reverse is not true.

## 🔁 Resetting release-please

`scaffold`'s manifest carries the template's own version, so a new repo resets it before its first release — release-please then proposes a first release PR after your first conventional commit on `main`:

<details>
<summary>The six reset steps</summary>

1. **Manifest** — set `.release-please-manifest.json` to `{ ".": "0.0.0" }` and `package.json` `version` to `0.0.0` (`release-type: node` bumps both).
2. **Changelog** — delete the inherited `CHANGELOG.md`.
3. **Config** — update `release-please-config.json` → `packages["."]["package-name"]` to your repo name.
4. **Workflow permissions** — in **Settings → Actions → General → Workflow permissions**, enable **Read and write permissions** so release-please can open its PR.
5. **Tags & releases (optional)** — if you copied the repo with history, drop old tags:

   ```bash
   git tag -l | xargs -r git tag -d
   ```

   …and clear any stale entries on the GitHub **Releases** tab.

6. **First commit** — push a Conventional Commit on `main` (`feat: …`, `fix: …`). release-please opens the initial release PR; merge it and your first tagged release ships.

</details>

## 💡 Why "scaffold" and not "template-\*"

Single word, brandable, language-neutral. Future stack-specific templates can sit next to it as `scaffold-laravel`, `scaffold-nuxt`, etc.

## 🤝 Contributing

PRs welcome. Conventional Commits required (enforced via commitlint). Husky runs the project's linters/formatters on `git commit`.

> [!TIP]
> Run `pnpm check:fix` before pushing — CI will catch what husky missed.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow.

## 🛣️ Versioning

[Semantic Versioning](https://semver.org/) via [release-please](https://github.com/googleapis/release-please) — see [CHANGELOG.md](CHANGELOG.md).

## 📄 License

[MIT](LICENSE) © [Titus Kirch](https://github.com/TitusKirch/) / [IT-Dienstleistungen Titus Kirch](https://kirch.dev)
