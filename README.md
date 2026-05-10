# Appliceo

French real estate / property management platform — a collection of related projects (web app, signing API, mobile apps, shared libraries) under one workspace folder.

This file is the **first read** for anyone joining the project. It is the canonical onboarding doc.

> **Note:** this folder is the **dev stack** repo — only the Docker compose + scripts for running everything in containers. Each sub-project listed below is its own independent git repo, cloned as a sibling folder inside this one and ignored by this repo's `.gitignore`.

---

## Quick start — Docker (recommended for Windows)

```bash
# 1. Clone this repo into the folder you want everything under
git clone git@github.com:appliceo/dev.git appliceo && cd appliceo

# 2. Clone all sibling projects automatically (idempotent — skips ones already there;
#    seeds .env from .env.example for each repo)
bash bin/clone-all.sh           # use bin/clone-all.ps1 on Windows PowerShell
                                # add --with-mobile to also pull the RN apps

# 3. Drop the DocuSign private key (out-of-band, not in git):
#    api/keys/docusign_private.key

# 4. Boot
docker compose up --build
```

Open:
- http://localhost:4321/fr/ — docuceo (with the lease editor mounted as a React island)
- http://localhost:5001/documentation — api Swagger
- http://localhost:8080/ — appliceo-php (V1)

Test user (seeded into both DBs on first startup):
- **Email**: `dev@appliceo.local`
- **Password**: `Test123!`

Full details, port overrides, HMR tuning and troubleshooting: `docker/README.md`.

Native (non-Docker) workflow on macOS / Linux still works per project — read each project's own `README.md`.

---

## Projects

| Directory | Stack | Status | Description |
|-----------|-------|--------|-------------|
| `appliceo-php/` | PHP (no framework), jQuery, MySQL, Docker | **Production (V1)** | Current live app. Lease management, tenants, properties, PDF generation. **Signed-lease workflow migrated to docuceo — PHP signed-lease code is FROZEN.** Branch: `develop`. |
| `appliceo-node/` | Next.js 16, React 19, Drizzle ORM, PostgreSQL 16, NextAuth v5, TailwindCSS 4 | **In development (V2)** | Full rewrite. Own PostgreSQL DB, English schema. Active code in `frontend/`. Branch: `develop`. **Not yet wired into the dev-stack docker-compose** — run locally with `npm run dev`. |
| `api/` | Fastify v5, PostgreSQL + Drizzle, Swagger | **v1.0 shipped** | Signing API + auth service. DocuSign-backed envelope creation, state, webhooks. JWT auth with V1 PHP fallback. **Account/identity = canonical source of truth here**; PHP `ap_users` is legacy fallback. |
| `lease-config/` | Pure TS, Zod 4 | **Stable** | Shared lease types/enums/validation. 9 lease types, 42 enums, V1 adapter (`fromV1` / `toV1`). |
| `ui/` | React 19, Headless UI (Catalyst pattern), TailwindCSS 4 | **Stable** | Shared UI library: `ThemeProvider`, form components, design tokens, icon system. |
| `docuceo/` | Astro 6, React 19, TailwindCSS 4, JWT auth | **In development** | Modern frontend shell. Astro SSR with React islands. Auth via api, SSR proxy to PHP. Lease editor source lives in-tree at `docuceo/src/lease-editor/`. |
| `EtatDesLieux/` | Expo SDK 54, RN 0.81, Ignite 11.3, WatermelonDB, MMKV | **In development** | Mobile app for property inspection reports (photos, rooms, offline-first). |
| `appliceo-design/` | HTML, CSS reference assets | **Reference** | Color palette, design token reference, examples. |

### Default branches

`appliceo-php`, `appliceo-node` → `develop`. Everything else → `main`. Standardisation on git-flow is planned but not yet done.

### Remotes

Target: every project under the `appliceo` GitHub org. A few are still in flight.

| Project | `origin` | Notes |
|---|---|---|
| dev-stack (this folder) | `appliceo/dev` | Holds `docker-compose.yml` + scripts |
| `api` | `appliceo/api` | Clever Cloud auto-deploy from GitHub |
| `ui` | `appliceo/ui` | |
| `lease-config` | `appliceo/lease-config` | |
| `docuceo` | `appliceo/docuceo` | Clever Cloud auto-deploy from GitHub |
| `appliceo-php` | `appliceo/appliceo-php` | Kept `appliceo-` prefix (legacy V1) |
| `appliceo-node` | `appliceo/appliceo-node` | Kept `appliceo-` prefix; not integrated into root compose yet |
| `EtatDesLieux` | `appliceo/etat-des-lieux` | |
| `appliceo-design` | *not in git — local only* | Reference assets, intentionally local |

---

## Domain glossary (French real estate)

| French | English |
|--------|---------|
| Entité | Property / building |
| Lot | Rental unit (apartment, garage, cellar, etc.) |
| Locataire | Tenant |
| Bail (pl. baux) | Lease |
| Propriétaire | Owner |
| Garant | Guarantor |
| Avis | Payment notice |
| État des lieux | Property inspection report |

### Lease type codes

| Code | Type |
|------|------|
| `h` | residential (habitation) |
| `c` | commercial |
| `p` | professional |
| `g` | garage |
| `f` | furnished (meublé) |
| `m` | mobility |
| `se` | seasonal |
| `s` | storehouse |
| `w` | cellar |

### Other conventions

- **Currency**: EUR.
- **Dates**: `DD/MM/YYYY` in UI, `YYYY-MM-DD` in DB.
- **Decimals**: comma in UI, dot in DB.
- **Rent indices**: IRL (residential), ILC (commercial), ILAT (professional). ICC also used.
- **Default UI language**: French.

---

## Databases

Two distinct databases. They no longer share a schema.

### V1 — MySQL (production)

- Database: `appliceo_php`
- Hosted: OVH (production), Docker MySQL 8.0 (local).
- All tables prefixed `ap_` (`ap_baux`, `ap_lots`, `ap_locataires`, `ap_entites`, `ap_users`, …).
- French column names (`id_bail`, `id_locataire`, `date_debut_bail`, …).
- 54+ tables.
- **Never** alter V1 schema without checking impact on the PHP app.

### V2 — PostgreSQL (in development)

- Database: `appliceo_v2`
- Hosted: Postgres 16 — Docker locally, Clever Cloud managed in prod (target).
- Schema defined in TypeScript: `appliceo-node/frontend/src/lib/db/schema/`.
- English column names. Lease split into 7 child tables. 24 tables total.
- Drizzle ORM + migrations.

### API — PostgreSQL (signing + auth)

- Same Postgres instance as V2 (separate scope).
- Tables: `ap_sig_envelopes`, `ap_sig_envelope_events`, `ap_auth_users`.
- Schema: `api/src/db/schema.ts`.

---

## Dependency graph

```
lease-config ──→ docuceo                   (file:)
              ──→ appliceo-node/frontend   (file:, planned)

ui           ──→ docuceo                   (file:)
              ──→ appliceo-node/frontend   (file:)

api          ──→ docuceo                   (JWT auth)
              ──→ appliceo-php             (signing endpoints + V1 credential verify via HTTP bridge)

docuceo      ──→ api                       (JWT login/register)
              ──→ appliceo-php             (SSR proxy for lease data, JWT in X-Authorization)
```

`file:` arrows mean an `npm` dependency installed via local path. After changes in a library, the consumer needs `npm install` (or `npm rebuild`) again.

The lease editor used to be a separate `lease-editor/` repo; on 2026-05-02 its source was collapsed into `docuceo/src/lease-editor/`. The static SPA path on the PHP V1 domain was retired in the same pass — `docuceo` is now the only home for the lease editor.

---

## Auth flow

```
Browser → docuceo (Astro SSR)
  ├─ Login/Register → api (Fastify) — canonical source of truth for accounts (ap_auth_users)
  │    └─ V1 fallback (legacy): api → HTTP POST → appliceo-php /api/auth/verify
  │         └─ PHP verifies credentials in ap_users (bcrypt + SHA512)
  │         └─ On success: user auto-migrated to ap_auth_users; PHP becomes read-only for that account
  ├─ Lease data → docuceo SSR proxy → appliceo-php (JWT via X-Authorization header)
  │    └─ PHP jwt-auth.php validates JWT, sets session, returns data
  └─ JWT stored in localStorage + is_authenticated cookie for SSR middleware
```

**Forward shape:** account/identity stays in api. Legacy PHP `ap_users` will be sunset alongside V1. Multi-profile / multi-role refactor (one account → tenant + landlord + accountant + …, no email-as-unique-id) kicks off PHP-side first; api + docuceo follow.

---

## Local vs remote backends

You can run everything locally, or point a consumer at the dev deployment.

| Service | Local (default) | Remote dev |
|---|---|---|
| `api` | `http://localhost:5001` | `https://api.appliceo.com/` |
| `appliceo-php` | `https://localhost:8443` (self-signed SSL) | `https://dev.appliceo.com/` (HTTP Basic Auth required) |

> **Basic Auth on `dev.appliceo.com`** is enforced at the `.htaccess` level. Credentials are not in the repo — ask the team. Each request must send `Authorization: Basic <base64(user:pass)>`. App-level JWT/session auth runs on top.

`api.appliceo.com` is live (single environment for now). A separate dev/staging environment will be carved off when the first production traffic arrives. PHP `appliceo.com` is planned but not live — V1 still serves at `dev.appliceo.com`.

### Switching a consumer

Each consumer ships a `.env.example` with both blocks:

```env
# ── LOCAL DEVELOPMENT (default) ──
PUBLIC_API_URL=http://localhost:5001
PUBLIC_PHP_API_URL=http://localhost:8443

# ── REMOTE DEV BACKENDS (uncomment to use) ──
# PUBLIC_API_URL=https://api.appliceo.com
# PUBLIC_PHP_API_URL=https://dev.appliceo.com
# PHP_BASIC_AUTH=base64(user:pass)
```

Some consumers also ship convenience scripts: `npm run dev:local` (default) and `npm run dev:remote`. See each project's README.

Env-var name varies by stack:

| Project | Env var(s) |
|---|---|
| `docuceo` | `PUBLIC_API_URL`, `PUBLIC_PHP_API_URL`, `PHP_BASIC_AUTH` |
| `appliceo-node/frontend` | `NEXT_PUBLIC_BACKEND_URL`, `DATABASE_URL`, `AUTH_SECRET`, `NEXT_PUBLIC_BASE_URL` |
| `EtatDesLieux` | `API_URL` (or `app/config/config.dev.ts` / `config.prod.ts`) |

---

## Hosting

| Service | Provider | Notes |
|---|---|---|
| `appliceo-php` (V1) | OVH shared hosting | Apache, MySQL. Deploy via rsync (`tools/deploy.sh`). No Composer on server. Dev domain Basic-Auth gated. |
| `api` | Clever Cloud (Node.js) | Managed Postgres (auth + signing tables). Env vars via CC console. |
| `docuceo` | Clever Cloud (Node.js) | Astro SSR. Server-side proxies to PHP and api. |
| `appliceo-node` (V2) | Clever Cloud (target) | Not yet deployed. Managed Postgres 16. |
| MySQL | OVH (V1 production) | Database `appliceo_php`. |
| PostgreSQL | Clever Cloud managed | Shared by `api` + `docuceo` (and target for `appliceo-node`). |

---

## Integrations

- **DocuSign** — electronic lease signing (JWT auth with RSA keys), via `api`. Yousign provider exists in `api/` but is deprecated since 2026-04-28; deletion queued for api v1.1.
- **Stripe** — subscription management (V1 has `ap_formules` + `ap_users_formules`). Forward plan: absorb into `api/` so all clients consume one source.
- **AR24** (eIDAS LRE) — registered mail delivery; planned to live in `api/` alongside DocuSign / Stripe.
- **Email** — transactional emails (notices, receipts, invoices, revision alerts).

---

## Prerequisites

Install once, reuse across projects:

- **Node.js 20+** and **npm** (some workflows use `--legacy-peer-deps` for RN apps).
- **Docker + Docker Compose** (for `appliceo-php` MySQL stack and `appliceo-node` Postgres).
- **PHP 8.2** (only if running `appliceo-php` outside Docker, which is uncommon).
- **Postgres 16** (or use the Docker compose file in `appliceo-node`).
- **Expo CLI** (`npm install -g expo-cli`) and Xcode / Android Studio for the two RN projects.

---

## Quick start per project

For each, `cd` into the directory and read its `README.md`. Short pointers:

| Project | One-liner |
|---|---|
| `appliceo-php` | `docker-compose up -d` → open `https://localhost:8443`. |
| `api` | `npm install` → `cp .env.example .env` → fill DocuSign creds → `npm run dev` (port 5001). |
| `appliceo-node` | `cd frontend && npm install` → `docker compose up -d` (Postgres) → `npm run db:push` → `npm run dev` (port 3000). |
| `docuceo` | `npm install` → `cp .env.example .env` → `npm run dev:local` (port 4321). Needs api + php running, or use `dev:remote`. |
| `lease-config` | `npm install` → `npm test`. Library only, no dev server. |
| `ui` | `npm install` → `npm run dev` (watch build) and/or `npm run storybook` (port 6007). |
| `EtatDesLieux` | `npm install --legacy-peer-deps` → `npm run start`. Needs Expo dev client build for full features. |

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for code-style rules, commit conventions, and the things you must **not** do (force-add files, commit `.env`, mention AI tools in commits, …).

---

## Per-project README index

- [api/README.md](./api/README.md)
- [appliceo-php/README.md](./appliceo-php/README.md)
- [appliceo-node/README.md](./appliceo-node/README.md)
- [ui/README.md](./ui/README.md)
- [lease-config/README.md](./lease-config/README.md)
- [docuceo/README.md](./docuceo/README.md)
- [EtatDesLieux/README.md](./EtatDesLieux/README.md)
