# Onboarding — recovering an existing clone

You already have the monorepo cloned locally but haven't touched it in a while (a few days, a sprint, a holiday). This guide takes you from "old checkout, unsure if it still works" to "current dev stack running cleanly". Works on macOS, Linux, and Windows (Git Bash).

> **First time on this machine?** Use `ONBOARDING-WINDOWS.md` (Windows) or just read it top-to-bottom on macOS/Linux — same flow, fewer caveats.

---

## TL;DR

```bash
cd /path/to/appliceo
bash bin/pull-all.sh
bash bin/secret.sh status
bash bin/configure.sh
bash bin/configure.sh --check
docker compose down && docker compose up --build
bash bin/status.sh
```

If `bin/status.sh` shows everything clean / in sync and the smoke probes at the bottom return 2xx/3xx — you're done.

---

## Step-by-step

### 1. Pull every sibling repo

```bash
bash bin/pull-all.sh
```

This iterates over the dev-stack root and every sibling (`api/`, `docuceo/`, `appliceo-php/`, …), fetches, and fast-forwards each one's current branch from origin. Will stop with a clear message if any repo has uncommitted local changes — resolve those first.

### 2. Confirm your age key still works

```bash
bash bin/secret.sh status
```

You should see:
- Your age public key
- A line per environment (`dev`, `prod`) saying you can decrypt it

If `dev` says you can't decrypt, your pubkey was either rotated out or never re-added. Ask the maintainer to re-grant before continuing.

### 3. Re-render configs

```bash
bash bin/configure.sh
```

Re-renders root `.env`, per-repo `.env`, and `docker/php/gestion-config.php` from `config/templates/` + `config/profiles/full-local.env` + decrypted dev secrets.

The renderer is hardened (atomic write, syntax check on PHP outputs, `${VAR}` substitution check) — if anything is wrong with the templates or your secrets, it exits non-zero **with the previous good file left in place**. Live config is never replaced by a broken render.

### 4. Drift-check

```bash
bash bin/configure.sh --check
```

Prints `in sync` and exits 0 when rendered files on disk match what the templates + current env would produce. If it prints `drift detected` and exits 1, something on disk diverged — usually because someone hand-edited a rendered file. Re-run without `--check` to overwrite.

### 5. Rebuild + restart the dev stack

```bash
docker compose down
docker compose up --build
```

`down` releases the bind-mounts cleanly (important — see "Bind-mount snapshot stuck" below). `--build` picks up Dockerfile changes if any landed.

Watch for the services finishing startup:
- PHP: Apache+FPM both up
- Docuceo: "Astro running at..."
- API: "Server listening at..."
- MySQL + Postgres: "ready for connections"

### 6. Verify

```bash
bash bin/status.sh
```

Shows current branch + ahead/behind + clean/dirty for every repo. Everything should be green / in sync (or you have intentional local commits ahead).

Smoke probes:

```bash
curl -sk -o /dev/null -w 'php   HTTP %{http_code}\n' https://localhost:8443/fr/administration/leases
curl -sk -o /dev/null -w 'astro HTTP %{http_code}\n' http://localhost:4321/
curl -sk -o /dev/null -w 'api   HTTP %{http_code}\n' http://localhost:5001/healthz
```

All three should return non-5xx. If something 5xxes, jump to the troubleshooting table.

---

## Common failure modes after a long absence

### "too many connections for role" on cleverCloud-managed PG

Out of scope for this runbook — see the project memory `project_pg_dev_prod_split` (2026-05-14) and the api `.env` `DATABASE_URL` value. Dev stack doesn't hit Clever Cloud PG; if you're seeing this, you're pointing the local stack at a remote addon.

### Bind-mount snapshot stuck (PHP returns HTTP 500 with empty body, nothing in `/var/log/php_errors.log`)

Docker Desktop's macOS bind mount can pin the inode of an older `docker/php/gestion-config.php` even after the host file has been rewritten. Symptom: `curl https://localhost:8443/anything` returns 500 with empty body, container view of the file is shorter / different than the host view.

```bash
docker compose restart php apache
```

This re-resolves the mount and the container picks up the current host file.

### Vendor mismatch (docuceo crashes complaining about `ui` or `lease-config` types)

The shared libs (`ui/`, `lease-config/`) are vendored into docuceo via file: links. After upstream changes, rebuild the vendored copy:

```bash
cd docuceo
npm run vendor:rebuild
cd ..
docker compose restart docuceo
```

### `.env` files unexpectedly absent

```bash
bash bin/configure.sh
```

It's idempotent. Just re-run.

### Secrets file fails to decrypt after a sops rotation you missed

```bash
git pull
bash bin/secret.sh status
```

Confirms the file decrypts. If still failing, the maintainer rotated your access — coordinate with them.

### `gestion-config.php` was generated truncated / partial (HTTP 500 with empty body, parse error in `/var/log/php_errors.log` inside container)

This was a real bug fixed 2026-05-14 — the renderer now does atomic writes with `php -l` verification, so it shouldn't recur. If you somehow have a truncated rendered file:

```bash
bash bin/configure.sh        # re-renders atomically with verify
docker compose restart php apache
```

### Browser cert warning on `https://localhost:8443/`

Self-signed dev cert — accept once per browser profile. Not a real problem.

### Port conflict (3306 / 5432 / 4321 / 5001 / 8443 / 8080 already in use)

Another process grabbed the port (another docker compose stack, a local Postgres, etc.). Stop it or edit `docker-compose.yml` to map a different host-side port.

### Mobile / EDL (Expo) build needed locally instead of via EAS cloud

```bash
cd EtatDesLieux
eas build --local
```

The EAS cloud queue can stall — `--local` is the escape hatch. (Memory: `feedback_mobile_local_build_fallback`.)

---

## Cleanup after recovery

Once everything's green:

```bash
# If you don't need the old containers' images anymore
docker system prune

# If you want to ditch local dev-stack volumes and start fresh next time
# WARNING: drops the local MySQL + Postgres data
docker compose down -v
```

The `-v` form is destructive — only use it if you're sure you don't need the local DB state (most contributors don't; the dev stack reseeds on next `up`).

---

## When to escalate

If the steps above don't get you back to a clean state, the likely culprits are:
- A breaking change in `config/templates/` that needs a corresponding secret you don't have access to → ask the maintainer.
- A schema migration that ran on someone else's machine but you missed → `cd appliceo-node && npm run db:migrate` (V2) or check `appliceo-php/migrations/`.
- A new dependency in `docker-compose.yml` (added service) that wasn't built → `docker compose build` explicitly, then `up`.

When in doubt: paste the failing command + full stderr to the maintainer with `bash bin/status.sh` output for context.
