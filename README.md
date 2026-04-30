# Appliceo

French real estate / property management platform — a collection of related projects (web app, signing API, mobile apps, shared libraries) under one workspace folder.

This file is the **first read** for anyone joining the project. It is the canonical onboarding doc.

> **Note:** this folder is the **dev stack** repo — only the Docker compose + scripts for running everything in containers. Each sub-project listed below is its own independent git repo, cloned as a sibling folder inside this one and ignored by this repo's `.gitignore`.

---

## Quick start — Docker (recommended for Windows)

```bash
# 1. Clone this repo into the folder you want everything under
git clone <this-repo-url> appliceo && cd appliceo

# 2. Clone the projects you need as sibling folders (folder name must match)
git clone <appliceo-api-url>            appliceo-api
git clone <appliceo-ui-url>             appliceo-ui
git clone <appliceo-lease-config-url>   appliceo-lease-config
git clone <appliceo-lease-editor-url>   appliceo-lease-editor
git clone <docuceo-url>                 docuceo

# 3. Drop the secrets you've been sent into the right paths:
#    appliceo-api/.env
#    appliceo-api/keys/docusign_private.key
#    docuceo/.env

# 4. Configure compose
cp .env.docker.example .env   # then edit and set PHP_BASIC_AUTH

# 5. Boot
docker compose up --build
```

Open:
- http://localhost:4321/fr/ — docuceo
- http://localhost:3001/ — lease-editor
- http://localhost:5001/documentation — api Swagger

Full details, port overrides, HMR tuning and troubleshooting: `docker/README.md`.

Native (non-Docker) workflow on macOS / Linux still works per project — read each project's own `README.md`.

---

## Projects

| Directory | Stack | Status | Description |
|-----------|-------|--------|-------------|
| `appliceo-php/` | PHP (no framework), jQuery, MySQL, Docker | **Production (V1)** | Current live app. Lease management, tenants, properties, PDF generation, DocuSign. Branch: `develop`. |
| `appliceo-node/` | Next.js 16, React 19, Drizzle ORM, PostgreSQL 16, NextAuth v5, TailwindCSS 4 | **In development (V2)** | Full rewrite. Own PostgreSQL DB, English schema. Active code in `frontend/`. Branch: `develop`. |
| `appliceo-api/` | Fastify v5, PostgreSQL + Drizzle, Swagger | **v1.0 shipped** | Signing API + auth service (DocuSign + Yousign), envelope state, webhooks. JWT auth with V1 PHP fallback. |
| `appliceo-lease-editor/` | Vite 7, React 19, TailwindCSS 4, TanStack Router/Query | **In development** | Config-driven lease form SPA. Standalone build at `/lease-editor/` on PHP domain + React island in docuceo. |
| `appliceo-lease-config/` | Pure TS, Zod 4 | **Stable** | Shared lease types/enums/validation. 9 lease types, 42 enums, V1 adapter (`fromV1` / `toV1`). |
| `appliceo-lease-editor-native/` | Expo SDK 54, RN 0.81, Ignite 11.4 | **Early development** | React Native version of the lease editor for signed leases. |
| `appliceo-ui/` | React 19, Headless UI (Catalyst pattern), TailwindCSS 4 | **Stable** | Shared UI library: `ThemeProvider`, form components, design tokens, icon system. |
| `docuceo/` | Astro 6, React 19, TailwindCSS 4, JWT auth | **In development** | Modern frontend shell. Astro SSR with React islands. Auth via api, SSR proxy to PHP. |
| `EtatDesLieux/` | Expo SDK 54, RN 0.81, Ignite 11.3, WatermelonDB, MMKV | **In development** | Mobile app for property inspection reports (photos, rooms, offline-first). |
| `appliceo-design/` | HTML, CSS reference assets | **Reference** | Color palette, design token reference, examples. |

### Default branches

`appliceo-php`, `appliceo-node` → `develop`. Everything else → `main`. Standardisation on git-flow is planned but not yet done.

### Remotes

Target: every project under the `appliceo` GitHub org. A few are still in flight.

| Project | Current `origin` | Notes |
|---|---|---|
| `appliceo-api` | `appliceo/appliceo-api` | Plus a Clever Cloud push-only remote `appliceo-api-dev` |
| `appliceo-lease-config` | `appliceo/lease-config` | |
| `appliceo-lease-editor` | `appliceo/lease-editor` | |
| `appliceo-node` | `appliceo/appliceo-node` | |
| `appliceo-ui` | `appliceo/appliceo-ui` | |
| `docuceo` | `appliceo/docuceo` | |
| `EtatDesLieux` | `appliceo/etat-des-lieux` | |
| `appliceo-php` | `pixeine/appliceo` | Migration to `appliceo/` planned (org-ownership transfer) |
| `appliceo-lease-editor-native` | *not in git — local only* | Project on hold |
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
- Schema: `appliceo-api/src/db/schema.ts`.

---

## Dependency graph

```
appliceo-lease-config ──→ appliceo-lease-editor    (file:)
                      ──→ docuceo                   (file:)

appliceo-ui          ──→ appliceo-lease-editor     (file:)
                     ──→ docuceo                    (file:)
                     ──→ appliceo-node/frontend     (file:)

appliceo-lease-editor ──→ docuceo                   (React island)
                      ──→ appliceo-php              (static build at /lease-editor/)

appliceo-api          ──→ docuceo                   (JWT auth)
                      ──→ appliceo-php              (signing endpoints + V1 credential verify via HTTP bridge)

docuceo               ──→ appliceo-api              (JWT login/register)
                      ──→ appliceo-php              (SSR proxy for lease data, JWT in X-Authorization)
```

`file:` arrows mean an `npm` dependency installed via local path. After changes in a library, the consumer needs `npm install` (or `npm rebuild`) again.

---

## Auth flow

```
Browser → docuceo (Astro SSR)
  ├─ Login/Register → appliceo-api (Fastify) → JWT issued
  │    └─ V1 fallback: appliceo-api → HTTP POST → appliceo-php /api/auth/verify
  │         └─ PHP verifies credentials in ap_users (bcrypt + SHA512)
  │         └─ On success: user auto-migrated to ap_auth_users (PG)
  ├─ Lease data → docuceo SSR proxy → appliceo-php (JWT via X-Authorization header)
  │    └─ PHP jwt-auth.php validates JWT, sets session, returns data
  └─ JWT stored in localStorage + is_authenticated cookie for SSR middleware
```

---

## Local vs remote backends

You can run everything locally, or point a consumer at the dev deployment.

| Service | Local (default) | Remote dev |
|---|---|---|
| `appliceo-api` | `http://localhost:5001` | `https://api-dev.appliceo.com/` |
| `appliceo-php` | `https://localhost:8443` (self-signed SSL) | `https://dev.appliceo.com/` (HTTP Basic Auth required) |

> **Basic Auth on `dev.appliceo.com`** is enforced at the `.htaccess` level. Credentials are not in the repo — ask the team. Each request must send `Authorization: Basic <base64(user:pass)>`. App-level JWT/session auth runs on top.

Production URLs (`api.appliceo.com`, `appliceo.com`) are planned but not live.

### Switching a consumer

Each consumer ships a `.env.example` with both blocks:

```env
# ── LOCAL DEVELOPMENT (default) ──
PUBLIC_API_URL=http://localhost:5001
PUBLIC_PHP_API_URL=http://localhost:8443

# ── REMOTE DEV BACKENDS (uncomment to use) ──
# PUBLIC_API_URL=https://api-dev.appliceo.com
# PUBLIC_PHP_API_URL=https://dev.appliceo.com
# PHP_BASIC_AUTH=base64(user:pass)
```

Some consumers also ship convenience scripts: `npm run dev:local` (default) and `npm run dev:remote`. See each project's README.

Env-var name varies by stack:

| Project | Env var(s) |
|---|---|
| `docuceo` | `PUBLIC_API_URL`, `PUBLIC_PHP_API_URL`, `PHP_BASIC_AUTH` |
| `appliceo-node/frontend` | `NEXT_PUBLIC_BACKEND_URL`, `DATABASE_URL`, `AUTH_SECRET`, `NEXT_PUBLIC_BASE_URL` |
| `appliceo-lease-editor` | Vite proxy (no client env) |
| `EtatDesLieux` | `API_URL` (or `app/config/config.dev.ts` / `config.prod.ts`) |
| `appliceo-lease-editor-native` | `EXPO_PUBLIC_API_URL` |

---

## Hosting

| Service | Provider | Notes |
|---|---|---|
| `appliceo-php` (V1) | OVH shared hosting | Apache, MySQL. Deploy via rsync (`tools/deploy.sh`). No Composer on server. Dev domain Basic-Auth gated. |
| `appliceo-api` | Clever Cloud (Node.js) | Managed Postgres (auth + signing tables). Env vars via CC console. |
| `docuceo` | Clever Cloud (Node.js) | Astro SSR. Server-side proxies to PHP and api. |
| `appliceo-node` (V2) | Clever Cloud (target) | Not yet deployed. Managed Postgres 16. |
| MySQL | OVH (V1 production) | Database `appliceo_php`. |
| PostgreSQL | Clever Cloud managed | Shared by `appliceo-api` + `docuceo` (and target for `appliceo-node`). |

---

## Integrations

- **DocuSign** — electronic lease signing (JWT auth with RSA keys), via `appliceo-api`.
- **Yousign** — alternative signing provider, via `appliceo-api`.
- **Stripe** — subscription management (V1 has `ap_formules` + `ap_users_formules`).
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
| `appliceo-api` | `npm install` → `cp .env.example .env` → fill DocuSign/Yousign creds → `npm run dev` (port 5001). |
| `appliceo-node` | `cd frontend && npm install` → `docker compose up -d` (Postgres) → `npm run db:push` → `npm run dev` (port 3000). |
| `docuceo` | `npm install` → `cp .env.example .env` → `npm run dev:local` (port 4321). Needs api + php running, or use `dev:remote`. |
| `appliceo-lease-editor` | `npm install` → `npm run dev` (port 3001). |
| `appliceo-lease-config` | `npm install` → `npm test`. Library only, no dev server. |
| `appliceo-ui` | `npm install` → `npm run dev` (watch build) and/or `npm run storybook` (port 6007). |
| `EtatDesLieux` | `npm install --legacy-peer-deps` → `npm run start`. Needs Expo dev client build for full features. |
| `appliceo-lease-editor-native` | `npm install --legacy-peer-deps` → `npm run web` (or `ios`, `android`). |

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for code-style rules, commit conventions, and the things you must **not** do (force-add files, commit `.env`, mention AI tools in commits, …).

---

## Per-project README index

- [appliceo-api/README.md](./appliceo-api/README.md)
- [appliceo-php/README.md](./appliceo-php/README.md)
- [appliceo-node/README.md](./appliceo-node/README.md)
- [appliceo-ui/README.md](./appliceo-ui/README.md)
- [appliceo-lease-editor/README.md](./appliceo-lease-editor/README.md)
- [appliceo-lease-config/README.md](./appliceo-lease-config/README.md)
- [appliceo-lease-editor-native/README.md](./appliceo-lease-editor-native/README.md)
- [docuceo/README.md](./docuceo/README.md)
- [EtatDesLieux/README.md](./EtatDesLieux/README.md)
