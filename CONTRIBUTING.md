# Contributing

House rules for everyone working on Appliceo. Read once, apply everywhere.

---

## Code style

### Functional programming, no classes

- **Use functional programming.** No `class`, no OOP inheritance for new code.
- Prefer **factory functions returning typed objects** over class constructors.
- Pure functions where possible. Avoid mutation. Minimise side effects.
- Determinism over cleverness — same inputs, same outputs.

> Existing PHP code (`appliceo-php`) is class-heavy by necessity. Don't fight it there. The rule applies to all the JS/TS/RN projects.

### Naming

- camelCase for variables and functions.
- PascalCase for types, React components, and (legacy) PHP classes.
- French is allowed in domain code where it reflects the underlying database (`bail`, `locataire`, `id_lot_1`). New V2 schema uses English.

### Comments

- Default to **no comments**.
- Add a comment only when the *why* is non-obvious — a hidden constraint, a workaround, a surprising invariant.
- Don't restate what the code says.

---

## Git

### Commits

- Commit messages and PR descriptions must be **neutral and descriptive** — no tool, vendor, or personal-assistant references; no `Co-Authored-By` trailers from non-humans; no naming personal local-only files.
- One logical change per commit. Subject line in imperative ("Add lease type config", not "Added…").
- Squash trivial fix-ups before merging.

### Branches

- `appliceo-php` and `appliceo-node` use `develop` as default. Everything else uses `main`.
- Feature branches: `feature/<short-description>`.
- Bug fixes: `fix/<short-description>`.
- Migrating to git-flow is on the roadmap; for now follow the existing pattern in each repo.

### What never goes in git

- `.env` and any other secret-bearing file.
- `.claude/`, `.cursor/`, `.aider*`, `.continue/`, or any other AI-tool config.
- `CLAUDE.md` and other AI-prompt files (treat as local-only).
- `.planning/` (local scratch / planning).
- Build output (`dist/`, `dist-lib/`, `build/`, `tsconfig.tsbuildinfo`, `node_modules/`).
- Logs, OS junk (`.DS_Store`, `Thumbs.db`).

The user's global gitignore (`~/.gitignore`) covers most of this, but **don't rely on it**: prefer adding entries to the project's own `.gitignore` for portability — except for AI/editor configs, which stay in the global file by team agreement.

### Things you must never run

- `git add -f` to bypass `.gitignore`. Respect ignores. If you genuinely need a tracked-yet-ignored file, talk about it first.
- `git push --force` on `main` / `develop`. Use `--force-with-lease` and only on your own feature branches.
- `git commit --no-verify` to skip pre-commit hooks. If a hook fails, fix the underlying issue.
- `git rebase -i` / `git add -i` from non-interactive scripts.

---

## Environment files

- Every project must ship a `.env.example` with sensible local defaults.
- Required env vars are documented in each project's README.
- For consumers that talk to backends (`docuceo`, `EtatDesLieux`, …), the example must include both **LOCAL** and **REMOTE** blocks (one commented out).
- Never commit a working `.env`.

---

## Tests & checks before pushing

Each project has its own toolchain. Defaults:

- TypeScript projects: `npm run typecheck` (or equivalent) before commit.
- Tests: `npm test` (Jest / Vitest / PHPUnit / Node test runner) for the touched project.
- Linter: where configured (`npm run lint` in node projects).

CI runs lint + typecheck + unit tests for projects that have them set up. E2E (Playwright in `appliceo-node`, Maestro in mobile apps) runs on demand.

---

## Pull requests

- One PR per feature / bugfix.
- Title: short, imperative, no jargon.
- Description: what changed, why, how to test. Link to any tracking issue.
- Screenshots / screencasts for UI changes.
- Don't merge your own PRs without a review unless explicitly agreed.

---

## Cross-project changes

- The dependency graph is in the root [README](./README.md). When you change a `file:`-linked library (`appliceo-ui`, `appliceo-lease-config`), bump consumers' lockfiles or run `npm install` there too.
- DB schema changes in V1 (`appliceo-php`) require checking the migration is idempotent and won't break the live app.
- DB schema changes in V2 (`appliceo-node`) go through Drizzle migrations.

---

## Domain knowledge

The product is a French real-estate / property-management platform. Read the **Domain glossary** section of the root README before working on lease / tenant / property logic — names, codes, and conventions are not arbitrary.
