# Docker dev stack — Appliceo

One `docker-compose.yml` to run the **whole stack** as containers — Postgres, MySQL, the PHP V1 app (Apache + PHP-FPM), the Fastify API, and docuceo (which hosts the lease editor in-tree). Built so Windows contributors don't need WSL, bash, or a Node toolchain on the host — only Docker Desktop. macOS / Linux dev still works through the same setup.

> `appliceo-node` (V2 frontend) is a sibling repo cloned alongside but **not yet wired into this compose stack** — run it locally with `npm run dev` from `appliceo-node/frontend/` for now.

## What runs

| Service        | Port(s)        | What it is                                              |
|----------------|----------------|---------------------------------------------------------|
| `postgres`     | 5432           | Postgres 16 (`appliceo_v2`) — for `api`                 |
| `mysql`        | 3306           | MySQL 8.0 (`appliceo_php`) — for the PHP V1 app         |
| `php`          | (internal)     | `php:8.2-fpm`. Runs PHP V1 migrations on startup.       |
| `apache`       | 8080 / 8443    | `httpd:2.4` reverse-proxying to `php`                    |
| `api`          | 5001           | `api` (Fastify, dev mode + HMR)                          |
| `docuceo`      | 4321           | `docuceo` (Astro SSR, HMR — in-tree lease editor)        |

All services live on the default compose network. Internal DNS uses service names: `api` reaches MySQL via `mysql:3306`, docuceo proxies PHP via `apache:80`, etc.

## First run

```bash
# 1. Clone all sibling repos + render every per-project .env from the central
#    config/templates/. Idempotent — re-runnable. appliceo-php is checked out on
#    `develop` automatically. clone-all auto-runs configure.sh at the end.
bash bin/clone-all.sh           # use bin/clone-all.ps1 on Windows PowerShell

# 2. Drop the DocuSign private key (out-of-band, not in git):
#    api/keys/docusign_private.key

# 3. Build & start
docker compose up --build
```

First start takes 3–8 min — it installs sibling deps into named volumes, runs `vendor:rebuild` for docuceo, and applies all PHP/Postgres migrations. Subsequent `docker compose up` reuses everything.

### Profiles

`bin/configure.sh` (auto-run by `clone-all.sh`) renders `.env` files from `config/templates/` using one of three profiles:

| Profile | What it points at |
|---|---|
| `full-local` *(default)* | API + PHP run locally in compose. Browser hits `apache:80` / `api:5001` via container DNS. |
| `frontends-only` | Frontends local, api + php = `https://api.appliceo.com` + `https://dev.appliceo.com`. Set `PHP_BASIC_AUTH` in `config/local.env`. |
| `staging` | Everything points at remote dev backends. Useful for sanity-checking against deployed code. |

```bash
bash bin/configure.sh --profile=frontends-only   # re-render with chosen profile
bash bin/configure.sh --check                    # exit 1 if any rendered file drifts from current config
```

User-only secrets (DocuSign, Stripe, basic-auth) go in `config/local.env` (gitignored). See `config/local.env.example`.

## Test user

Both DBs are seeded with one local-only test user on first startup (idempotent — re-runs are no-ops):

| Field | Value |
|---|---|
| Email | `dev@appliceo.local` |
| Password | `Test123!` |
| User ID | `1` |

Login flows in docuceo and the V1 PHP app accept this user. The password complies with the PHP password policy (≥8 chars, upper + lower + digit + special).

## Endpoints

When the stack is ready, open:

- http://localhost:4321/fr/ — docuceo (front of the modern stack, with the lease editor mounted as a React island)
- http://localhost:5001/documentation — API Swagger
- http://localhost:8080/ — appliceo-php V1 (HTTP)
- https://localhost:8443/ — appliceo-php V1 (HTTPS, self-signed cert — accept the warning)

Database CLIs:
```bash
psql postgresql://appliceo:appliceo_dev@localhost:5432/appliceo_v2
mysql -h localhost -u appliceo -pappliceo123 appliceo_php
```

## Day to day

```bash
docker compose up                  # start everything (foreground, logs)
docker compose up -d               # start detached
docker compose logs -f docuceo     # follow one service
docker compose restart api         # restart a single service
docker compose down                # stop, keep volumes
docker compose down -v             # stop + wipe volumes (full reset, re-seeds DBs)
```

HMR works across bind mounts — edit `docuceo/src/lease-editor/...` on the host, the container picks it up and the browser reloads.

## Tuning

### Polling vs native fs events

`CHOKIDAR_USEPOLLING=true` is the default. Reliable on Windows hosts where source lives on `C:\…` (NTFS). Cost: ~5–15% idle CPU per Node service.

If your source lives **inside WSL2** (e.g. `\\wsl$\Ubuntu\home\you\code\appliceo`) or you're on macOS / Linux, set `CHOKIDAR_USEPOLLING=false` in `.env` for lower idle CPU — native filesystem events propagate fine.

### Port clashes

Override `PORT_DOCUCEO`, `PORT_API`, `PORT_POSTGRES`, `PORT_MYSQL`, `PORT_PHP_HTTP`, `PORT_PHP_HTTPS` in `.env`. Only the host side changes — internal container ports stay fixed.

### Pointing at remote backends

By default the docuceo proxy targets the local `apache` container. To use the deployed dev backends instead, override in your local `.env`:

```env
PUBLIC_PHP_API_URL=https://dev.appliceo.com  # docuceo proxy target
PHP_BASIC_AUTH=$(printf '%s' 'user:password' | base64)
```

`dev.appliceo.com` enforces HTTP Basic Auth at the `.htaccess` level; ask the team for credentials.

## Pushing config to Clever Cloud

Two apps deploy on Clever today: `api` and `docuceo`. Their env vars are kept in sync with the same `config/` system, via:

```bash
# Dry-run: show diff for both apps
bash bin/clever-sync.sh

# First time on this machine — pull current secrets from Clever into config/clever.local.env (gitignored)
bash bin/clever-sync.sh --bootstrap

# Push (prompts [y/N] per app)
bash bin/clever-sync.sh --apply                  # both apps
bash bin/clever-sync.sh --app=api --apply        # one app
```

Output legend: 🟢 add · 🟡 update · ⚪ match (`--verbose`) · 🔴 orphan (in Clever, not in template — never auto-removed).

Source order (later wins): `config/defaults.env` → `config/profiles/clever.env` → `config/clever.local.env`. The DocuSign private key is read from `api/keys/docusign_private.key` (override path with `DOCUSIGN_PRIVATE_KEY_FILE` in `clever.local.env`) and base64-encoded at sync time — no inline blob duplication.

Per-app templates live in `config/templates/clever/`. Push uses `clever env set` per-key (additive — never wipes addon vars like `POSTGRESQL_ADDON_*`).

Requirements: `clever` CLI logged in, `jq`, `gettext` (`envsubst`), Bash 4+.

## Variants (prod, test)

Compose overlays for non-dev scenarios are stubs in this repo:

```bash
# Prod (when filled in):
docker compose -f docker-compose.yml -f docker-compose.prod.yml up

# CI / test:
docker compose -f docker-compose.yml -f docker-compose.test.yml up
```

The base `docker-compose.yml` is local-dev. The overlays are not yet wired for actual deploy — they're placeholders documenting intent.

## What's bind-mounted vs volume

Source code: bind-mounted from host (so edits hot-reload).
`node_modules`: **named volumes** — never bind-mounted from host. Avoids Windows filesystem perf hit and prevents Windows-built native modules from contaminating Linux containers.
`docuceo/vendor/`: bind-mounted (host's `package.json` stubs need to be visible inside the container; vendor-rebuild's text-only output is safe to write back).
`mysql_data`, `pg_data`: named volumes for DB persistence.

Sibling deps (`ui`, `lease-config`) get installed once by the `siblings-init` service before docuceo starts. The init is idempotent — it skips already-installed packages on subsequent runs.

## Troubleshooting

**`siblings-init` exits with code 1.** Check `docker compose logs siblings-init`. Usually a failed `npm install` — fix the underlying issue and re-run `docker compose up siblings-init`.

**`docuceo` blocked on `vendor-rebuild`.** First start can take a few minutes for the `ui` + `lease-config` lib builds. Tail `docker compose logs -f docuceo` to monitor.

**`getaddrinfo ENOTFOUND postgres`.** Cold-start DNS race — already mitigated by a TCP wait in `api/Dockerfile.dev`. If it returns, increase the wait or restart api.

**HMR not firing on Windows.** You probably have `CHOKIDAR_USEPOLLING=false`. Set to `true`.

**`docuceo` can't reach the api.** Inside the docuceo container, the API is at `http://api:5001` (not `localhost`). The `PUBLIC_API_URL` env var is already set to the right value by compose.

**Login fails with 401 — wrong creds.** Make sure you're using the seeded test user `dev@appliceo.local` / `Test123!`, not your production creds.

**PHP container collides with the standalone `appliceo-php/docker-compose.yml`.** Stop the standalone first: `(cd appliceo-php && docker compose down)` before bringing up the root compose.

**Permission denied on `api/keys/docusign_private.key`.** The file must exist locally — `api` reads it at startup via the bind mount. Without DocuSign creds, login/register still work; signing endpoints fail.

## Stopping cleanly

`docker compose down` keeps DB and node_modules volumes — next start is fast and DBs retain data.
`docker compose down -v` deletes everything; next start re-runs siblings-init and re-seeds both DBs from scratch.
