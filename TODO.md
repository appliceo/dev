# Appliceo — Consolidated TODO

> Single root-level scoreboard of pending work across the monorepo. Pulled from `.planning/*` plans and project memory on 2026-05-15.
> Detailed rationale + design lives in the underlying plan files (cited inline). When in doubt, this file wins.

## How to read this

- **Active** — someone is or should be working on it now
- **Blocked** — has a real external dependency (client, third-party, infra access)
- **Parked** — deferred by decision; trigger condition noted
- **Reference** — informational only, no work item

Items are grouped by primary owner (`api`, `docuceo`, `appliceo-php`, `appliceo-node`, `infra`, `cross-project`). Each line ends with `← source-plan.md` for traceability.

---

## 🔑 Cross-cutting gate: multi-profile rework

> **Multi-profile / multi-role accounts** (one identity → tenant + landlord + accountant + agency, across many entities). Email is no longer a unique id. Schema work kicks off PHP-side first; api + docuceo follow once shape stabilises. Currently parked — no plan filed. ← `PLAN-docuceo-user-accounts-2026-05-10.md`

**Items gated on multi-profile landing** (10):

- Stripe billing — agency-as-user model (who pays per-lease fee) — api Parked
- Stripe billing — account-management UI surface (SEPA, methods, history) — api Parked
- Account erasure — Stripe data deletion path — api Parked
- Email-change UX (steps 2 + 3 of the change roadmap) — api Parked
- Phase G — PG master data (entities / units / tenants) one-way PHP→docuceo import — docuceo Parked
- EDL Property model V2-schema alignment — EtatDesLieux Active (gates loading directly from V1 or V2)
- Delete-account UI rework — docuceo Active (build now under today's single-role semantic; rework when multi-profile lands)
- (Plus 3 secondary gates: B2C SEPA copy, AR24 erasure path, multi-profile schema kickoff itself)

When multi-profile starts moving, **un-park 7+ items at once**. Worth treating as the next strategic kickoff point.

---

## api/ — Active

- [ ] Slim `@fastify/swagger` + `@fastify/swagger-ui` out of the prod install: dynamic import inside the `SWAGGER_UI_ENABLED` gate, move both packages to `devDependencies`, drop `CC_NODE_DEV_DEPENDENCIES=install` from `clever-prod.env`. Config gate already in place (2026-05-15). ← api/.planning/PLAN-SLIM-SWAGGER-FROM-PROD.md
- [ ] Envelope worker: resolve DocuSign idempotency pattern (dedup-key vs claim row) ← PLAN-ENVELOPE-WORKER
- [ ] Envelope worker: signer-email-missing UX (UI prompt vs refuse) ← PLAN-ENVELOPE-WORKER
- [ ] Envelope worker: multi-instance startup race (`FOR UPDATE SKIP LOCKED` vs advisory lock) ← PLAN-ENVELOPE-WORKER
- [ ] Tenant DocuSign signing email non-delivery — diagnose: signer extraction (was only one signer sent?), DocuSign envelope payload (recipients listed?), DocuSign dashboard, spam filter. 5-step diagnostic in archived PLAN-LEASE-SIGNING-POLISH §3. ← archived PLAN-LEASE-SIGNING-POLISH

## api/ — Parked

- [ ] FP refactor (DocuSignProvider, SigningProviderFactory, SigningService, LeaseService → factory functions) — Yousign deletion now done (2026-05-15), so this is unblocked ← api/.planning/PLAN-FP-REFACTOR
- [ ] CORS hardening (Option 1 — SSR proxy + locked-down api CORS) — trigger: first real user or first data migration ← PLAN-api-cors-hardening
- [ ] Stripe billing — agency-as-user model: when an agency-typed user exists alongside a property owner, who pays the per-lease fee? Affects `payer_user_id` + possible `on_behalf_of_user_id` column. Trigger: multi-profile rework lands. ← archived PLAN-stripe-integration (Q1+Q2)
- [ ] Stripe billing — account-management UI surface for billing (SEPA enable, saved methods, credit pack visibility, invoices, history). Endpoints (`/billing/me/settings`, `/billing/credits`, `/billing/setup-intents`) designed in archived plan; UI is docuceo-side. Trigger: multi-profile UX firms up. ← archived PLAN-stripe-integration (Q3)
- [ ] Stripe billing — B2C SEPA signature-gating copy: when SEPA is eventually exposed to B2C tenants, signature unlock waits on `payment_intent.succeeded` (5-day delay shown), never on `processing`. Trigger: SEPA exposure decision. ← archived PLAN-stripe-integration (Q4)
- [ ] Account erasure — Stripe data deletion path: when an account is deleted, what happens to Stripe customer + saved payment methods + invoice history? Trigger: explicit policy decision (probably: detach methods, keep invoices for tax retention, anonymise customer). ← archived PLAN-docuceo-account-management
- [ ] Account erasure — AR24 (eIDAS LRE) export/delete path. Trigger: AR24 lands per `PLAN-ar24-integration` (currently parked). ← archived PLAN-docuceo-account-management
- [ ] Email-change UX (steps 2 + 3 of the email-change roadmap: verify new address before swap, audit + safety window). Trigger: after multi-profile lands (since multi-profile changes the "one email per account" invariant). ← archived PLAN-docuceo-account-management

---

## docuceo/ — Active

> Per-phase status lives in `docuceo/.planning/ROADMAP.md` (undated, in-place). Only the items still requiring work are listed below.

- [ ] Delete-account UI with mandatory signed-lease archive export gate — full GDPR erase, but archive export must complete first. Build against today's single-role semantics; multi-profile rework (parked) will redo account UX anyway. Non-trivial: archive-before-delete UX, irreversibility confirm, post-delete redirect, DocuSign envelope void best-effort. API side is already wired (`/auth/me/erase` + `ap_auth_erasures` audit). ← docuceo/.planning/ROADMAP.md Phase E + memory `project_gdpr_erase_full`

## docuceo/ — Parked

- [ ] Phase H deferred: lease-type page intro copy + SEO landing surface (commit 4 of SEO-FOUNDATION) — trigger: legal-text validation layer decision ← docuceo/.planning/ROADMAP.md Phase H
- [ ] Phase C2: seasonal (`se`) lease type — trigger: definition firms up ← docuceo/.planning/ROADMAP.md Phase C2
- [ ] Phase G: PG master data (entities / units / tenants) + one-way PHP→docuceo import — trigger: multi-profile lands ← docuceo/.planning/ROADMAP.md Phase G

### Reference
- Lease-subsystem long-tail (Phase 2 freeze + Phase 3 cross-repo synergies) ← docuceo/.planning/LEASES-PHASE-2-3-SKETCH.md
- Lease editor highlight UX ← docuceo/.planning/PLAN-LEASE-EDITOR-HIGHLIGHT-2026-05-08.md
- PDF export e2e test ← docuceo/.planning/PLAN-PDF-EXPORT-TEST-2026-05-08.md

---

## appliceo-php/ — Active

- [ ] Stripe bridge endpoints `GET|PUT /api/users/{id}/stripe-customer-id` for api reconciliation ← archived PLAN-stripe-integration
- [ ] Validation refactor — 99 PHP validation methods across Entite/Lot/Locataire/Bail with 0% reuse, target: single source of truth + JS+PHP unification + PHPUnit-testable ← appliceo-php/.planning/PLAN-validation-refactor
- [ ] Audit the 3 lingering signed-lease-adjacent columns (`is_signed`, `signing_date`, `signing_place`) — decide per column: (a) drop via migration if truly orphan; (b) keep + document as "offline-signing metadata" (where + when paper was signed offline); (c) preserve for the V1→docuceo lease-import path so legacy leases keep their signing date/place when migrated. Touched by `admin.leases.edit.php`, `admin.leases.create.editor-data.php`, `admin.leases.save.editor-data.php`, `en.php`, and 4 tests. ← decided 2026-05-15 during cleanup pass

> Signed-lease **workflow** has been DELETED from appliceo-php — the validate → lock → render+sign-PDF flow is gone; only migration history remains. Three `signing_*` columns (`is_signed`, `signing_date`, `signing_place`) still referenced by edit/save code — pending audit (see below). docuceo is the source of truth for signing (see memory `project_signed_lease_migration`).

---

## appliceo-node/ — Parked (project paused; resume-from-clean baseline restored 2026-05-15)

> Build is green; tooling is sane; package-lock fresh. When V2 resumes, start from `develop` and you won't hit a `Cannot find module 'ui'` wall. Below are the residual items the audit surfaced — none block running the dev server, all are real work for when V2 picks up.

- [ ] Fix `pays_proprietaire` test-fixture vs schema drift — Zod schema expects `number`, test fixtures pass `string`. 3 test suites failing on this: `validation/leaseFormValidation.test.ts`, `integration/leaseFormIntegration.test.ts`, `components/AddLease.test.tsx`. Surfaced 2026-05-15 after fixing the Jest `moduleNameMapping → moduleNameMapper` typo that had been masking real test runs.
- [ ] Lint backlog: `eslint .` reports 4876 issues (4779 auto-fixable). Trigger: V2 resume — running `eslint . --fix` is throwaway if the code gets rewritten significantly. Decision at resume: auto-fix once + commit, OR rebuild with the new code style as it lands.
- [ ] Migrate Property-shape into EDL — duplicate of `EtatDesLieux/` Active item but the V2 side is the upstream definition. When the V2 schema for properties firms up, EDL aligns to it (memory `project_edl_property_shape_unification`).

## appliceo-node/ — V2 reboot context (kept for resume orientation)

V2 rewrite is deferred per root CLAUDE.md; will resume when docuceo + api hit feature parity. As of the 2026-05-15 audit:
- Build: green
- Lint: runs (with 4876-issue backlog)
- Tests: 13 pass / 33 fail (the 33 are real schema-vs-fixture bugs, not config blockers)
- Last meaningful frontend commit: 2026-05-02 (`use the new "ui" package…`)
- Schema sources committed; 0000 drizzle migration matches

---

## EtatDesLieux/ — Active

- [ ] Replace placeholder `Property` model with V2-aligned schema so the EDL property shape matches appliceo (V1 MySQL + V2 PG). Goal: EDL can LOAD properties directly from V1 (via PHP api bridge) or V2 (Postgres via api) without remapping. Touches `app/db/models/Property.ts` (currently the only model whose 12 TS errors remain unfixed in develop — intentionally, pending this work) + the schema migration to keep tester local data additive-only (memory `project_edl_testers_real_data`). ← decided 2026-05-15

## EtatDesLieux/ — Reference

- `.planning/WEB-COMPAT-PLAN.md` — web mode broken (Babel decorator transform); separately tracked.
- `.planning/RELEASE-AUTOMATION.md` — EAS release pipeline doc.
- `.planning/PLAN.md` — current rolling plan.

---

## infra / dev-stack — Active

- [ ] Env profile drift policy — teach `bin/check-profiles.sh` about per-key categories (`# CATEGORY: cc-only | local-only | shared`) so legit per-env gaps stop being flagged. 2026-05-15: filled api-runtime keys (NODE_ENV, PORT, SIGNING_PROVIDER, SWAGGER_*, JWT_*, DOCUSIGN_BASE_PATH); the remaining 8 flags (`CC_*`, `HOST`, `APP_PORT`, `APP_PROTOCOL`) are all legit per-env, not gaps — fix is policy + script work, not value-filling. ← ENV-PROFILE-KEY-ALIGNMENT
- [ ] Review hook portability across sub-repos: monorepo root has `hooks/pre-commit` (prod-secret + SOPS-encryption guards) auto-installed via `core.hooksPath=hooks`. Sub-repos have no committed hooks. Decision needed: (a) keep root-only; (b) port slim "no .env / no private keys / no plaintext credentials" hook to each sub-repo with self-install on `npm install`; (c) walk-all-sub-repos hook in root. Pros: uniform guard. Cons: each sub-repo needs bootstrap, hooks must reference scripts that exist in that repo. ← decided 2026-05-15

## infra / dev-stack — Blocked

- [ ] Secrets rotation day: replace dev + prod values in SOPS, push to Clever Cloud env panel, merge new constants in PHP. Phase 1–3 of SECRETS-HARDENING shipped; only the rotation execution remains. Blocked on colleague availability + OVH/CC admin access window. ← SECRETS-HARDENING archive
- [ ] WordPress dev DB: clone prod schema, anonymise, separate creds — blocked on OVH admin access ← WORDPRESS-EXTRACT-TODO
- [ ] WordPress DB password + salt rotation — blocked on OVH admin access + colleague availability ← WORDPRESS-EXTRACT-TODO
- [ ] Prod CC app stand-up for api + docuceo on `main` branches (currently both deploy from `develop`) ← docker/CLAUDE.md "Open work to do this properly"

## infra / dev-stack — Parked

- [ ] WordPress repo isolation: separate repo vs submodule vs archive — trigger: decision needed first ← WORDPRESS-EXTRACT-TODO
- [ ] PG dev/prod split execution: spin up prod-tier CC PG addon (NOT DEV plan) when prod app stands up — see memory `project_pg_dev_prod_split` (2026-05-14 decision)

---

## cross-project — Active

- [ ] Resolve 13 client-pending lease-template clarifications (A.1, B.2–3, C.1/3–4, D.1–5, E.1–4) — gated on client response ← PLAN-INTEGRATION-CONTRATS
- [ ] A.2bis: `agency_activity` form field — label enum vs free text + position in Parties section ← PLAN-INTEGRATION-CONTRATS

## cross-project — Parked

- [ ] AR24 (eIDAS LRE) integration — trigger: sales contract signed + sandbox creds + same-IP constraint verified vs CC NAT egress ← PLAN-ar24-integration
- [ ] Multi-profile / multi-role accounts (one identity → tenant + landlord + accountant) — trigger: schema work kicks off PHP-side first ← PLAN-docuceo-user-accounts (see also the "Cross-cutting gate" section at the top)

---

## e2e/ — Active

> Current coverage (committed 2026-05-15 `8bfa05b`): smoke, login, lease-create, lease-pdf, api-token-fixture. Profiles `local-docker` + `cc-dev` driven by `TEST_ENV` env var via `@appliceo/test-fixtures` workspace.

- [ ] Add specs as new user-facing features ship. Next obvious gaps: account-management flows (change-password, forgot-password, email-verification) since those are now in docuceo; delete-account flow when its UI lands. ← PLAN-e2e-playwright
- [ ] CI integration decision — the original plan deliberately skipped CI ("no CI in this iteration"). Revisit when (a) team size grows, (b) Clever Cloud auto-deploy needs a pre-deploy gate, or (c) release cadence makes manual runs too lossy. ← PLAN-e2e-playwright

---

## Notes

- This file is **the** TODO. Per-plan files in `.planning/` provide rationale and design but their checklists may be partial — when a plan-file checkbox conflicts with this file, this file is right.
- Items get checked off here as they ship; if a plan's checklist is now stale, prefer updating this file over editing the plan.
- Cleanup pass that produced this file archived: AUDIT-REPORT-2026-03-10, ENUM-AUDIT-2026-03-13, DECISION-i18n-stack, DECISION-multi-value-storage, PLAN-CLEANUP-2026-05-10, PLAN-API-DOCS-2026-05-10, TESTING-HARDENING-2026-05-12, PLAN-INTEGRATION-CONTRATS-EXEC-2026-05-08, CROSS-PROJECT-STATUS-2026-05-02, SECRETS-HARDENING-2026-05-13 (Phase 1–3 shipped; rotation step now lives above). See `.planning/archive/`.
