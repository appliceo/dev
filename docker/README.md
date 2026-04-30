# Docker dev stack — Appliceo

One `docker-compose.yml` to run **lease-editor**, **docuceo**, **appliceo-api** and **Postgres** as containers. Built so Windows contributors don't need WSL, bash, or Node toolchain on the host — only Docker Desktop. macOS / Linux dev still works through the same setup.

## What runs

| Service        | Port  | What it is                                  |
|----------------|-------|---------------------------------------------|
| `postgres`     | 5432  | Postgres 16 (`appliceo_v2` DB)              |
| `api`          | 5001  | `appliceo-api` (Fastify, dev mode + HMR)    |
| `lease-editor` | 3001  | `appliceo-lease-editor` (Vite, HMR)         |
| `docuceo`      | 4321  | `docuceo` (Astro SSR, HMR)                  |

PHP backend stays **remote** — calls go to `https://dev.appliceo.com` (HTTP Basic Auth required).

## First run

```bash
# 1. Copy the compose-only env template and fill in PHP_BASIC_AUTH
cp .env.docker.example .env
# then edit .env: PHP_BASIC_AUTH=$(echo -n 'user:pass' | base64)

# 2. Make sure each service has its own .env locally (secrets):
#    - appliceo-api/.env  (DocuSign keys, JWT_SECRET, etc.)
#    - docuceo/.env       (anything the app reads at runtime)
#
#    Compose loads them via env_file. They are never committed.

# 3. Build & start
docker compose up --build
```

First start takes 3–8 min — it installs sibling deps once into named volumes and runs `vendor:rebuild` for docuceo. Subsequent `docker compose up` reuses everything.

When you see:

```
[lease-editor] url:   http://localhost:3001
docuceo dev server running on http://0.0.0.0:4321
{ "level":30, ..., "msg":"Server listening at http://0.0.0.0:5001" }
```

…the stack is ready. Open:

- http://localhost:3001/ — lease-editor SPA
- http://localhost:4321/fr/ — docuceo
- http://localhost:5001/documentation — API Swagger

## Day to day

```bash
docker compose up                  # start everything (foreground, logs)
docker compose up -d               # start detached
docker compose logs -f docuceo     # follow one service
docker compose restart api         # restart a single service
docker compose down                # stop, keep volumes
docker compose down -v             # stop + wipe volumes (full reset)
```

HMR works across the bind mount — edit `appliceo-lease-editor/src/App.tsx` on the host, the container picks it up and the browser reloads.

## Tuning

### Polling vs native fs events

`CHOKIDAR_USEPOLLING=true` is the default. This is reliable on Windows hosts where source lives on `C:\…` (NTFS). Cost: ~5–15% idle CPU per Node service.

If your source lives **inside WSL2** (e.g. `\\wsl$\Ubuntu\home\you\code\appliceo`) or you're on macOS / Linux, set `CHOKIDAR_USEPOLLING=false` in `.env` for lower idle CPU — native filesystem events propagate fine.

### Port clashes

Override any of `PORT_LEASE_EDITOR`, `PORT_DOCUCEO`, `PORT_API`, `PORT_POSTGRES` in `.env`. Only the host side changes — internal container ports stay fixed.

### Pointing at a different backend

- `PHP backend`: edit `PUBLIC_PHP_API_URL` (docuceo) and `PHP_API_URL` (lease-editor) in compose `environment:` if you need to hit prod or a local PHP container.
- `API`: docuceo talks to the api container via `http://api:5001` (Docker DNS). To swap in a remote API, set `PUBLIC_API_URL` to e.g. `https://api-dev.appliceo.com` in `docuceo/.env`.

## What's bind-mounted vs volume

Source code: bind-mounted from host (so edits hot-reload).
`node_modules` and `docuceo/vendor`: **named volumes** — never bind-mounted from host. This avoids the Windows filesystem perf hit and prevents Windows-built native modules from contaminating Linux containers.

Sibling deps (`appliceo-ui`, `appliceo-lease-config`, `appliceo-lease-editor`) get installed once by the `siblings-init` service before lease-editor and docuceo start. The init is idempotent — it skips already-built artefacts on subsequent runs.

## Troubleshooting

**`siblings-init` exits with code 1.** Check `docker compose logs siblings-init`. Usually means an `npm install` failed — fix and re-run `docker compose up siblings-init` then bring everything else up.

**HMR not firing on Windows.** You probably have `CHOKIDAR_USEPOLLING=false`. Set to `true`.

**`docuceo` can't reach the api.** Inside the docuceo container, the API is at `http://api:5001` (not `localhost`). The `PUBLIC_API_URL` env var is already set to the right value by compose.

**Lease list says "indisponible".** `PHP_BASIC_AUTH` is missing or wrong. Generate with `echo -n 'user:pass' | base64`.

**Permission denied on `appliceo-api/keys/docusign_private.key`.** Make sure the file exists locally — the api container reads it at startup via the bind mount. Without DocuSign creds, login/register still work; signing endpoints fail.

## Stopping cleanly

`docker compose down` keeps DB and node_modules volumes — next start is fast.
`docker compose down -v` deletes everything; next start re-runs siblings-init from scratch.
