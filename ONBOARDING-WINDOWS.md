# Onboarding — Windows

This guide walks a new Windows contributor from a blank machine to a running Appliceo dev stack. The same flow works on macOS / Linux with two cosmetic differences (installer commands, no FIFO workaround) — those platforms can read this top-to-bottom and skip the explicitly Windows-only callouts.

> **Already have an old clone and just need it working again after a pull?** See `ONBOARDING-EXISTING-CLONE.md` instead.

---

## 0. Pre-flight

### Pick a shell

Three viable shells exist on Windows. They are not interchangeable for this repo.

| Shell | Recommendation | Why |
|---|---|---|
| **Git Bash** | ✅ Use this | The `bin/*.sh` scripts assume bash; all docs assume Unix paths. Comes with Git for Windows. |
| **WSL2 (Ubuntu/Debian)** | Alternative | Works, but you're then a Linux user — install age/sops/docker inside WSL, not Windows. Docker Desktop's WSL2 integration must be enabled. |
| **PowerShell** | ❌ Avoid | No `.ps1` equivalents shipped. The `bin/*` flow is bash-only. |

The rest of this guide assumes **Git Bash**.

### ⚠ Before you clone — move out of cloud-sync folders

`bin/configure.sh` renders **plaintext secrets** into each project's `.env` and `gestion/config.php`. They're gitignored, but **cloud sync (Dropbox / OneDrive / iCloud) doesn't read `.gitignore`** — it watches the filesystem and uploads everything, keeping version history forever.

Other failure modes if the repo lives in a synced folder:
- The sops `--no-fifo` edit creates a brief plaintext temp file in `TMPDIR` (already worked around — see step 2 below — but only if `TMPDIR` itself is outside the sync tree).
- Cloud sync can write to `.git/index` mid-operation and corrupt the repo silently.

**Pick a non-synced location.** Recommended:

```
C:\dev\appliceo\
```

Any local-only path is fine — `C:\src\`, `C:\code\`, `C:\Users\<you>\dev\`. Verify from inside the repo later with `pwd` — if the output contains `Dropbox`, `OneDrive`, `iCloud`, you need to move.

---

## 1. Install tools

You need `git`, `docker`, `age`, and `sops` on your PATH. Pick whichever package manager you already use.

### winget (built into Windows 11)

```powershell
winget install Git.Git
winget install Docker.DockerDesktop
winget install FiloSottile.age
winget install Mozilla.SOPS
```

### Scoop

```powershell
scoop install git
scoop install age
scoop install sops
# Docker Desktop: install separately from https://docker.com/products/docker-desktop
```

### Chocolatey

```powershell
choco install git docker-desktop age sops -y
```

### Manual fallback for age / sops

If the package manager paths above don't work, download the binaries and put them on PATH:
- age: https://github.com/FiloSottile/age/releases (look for `age-vX.Y.Z-windows-amd64.zip`)
- sops: https://github.com/getsops/sops/releases (look for `sops-vX.Y.Z.windows.amd64.exe` — rename to `sops.exe` and place on PATH)

### Verify

Open Git Bash and check everything is reachable:

```bash
which git docker age age-keygen sops
git --version
docker --version
age --version
sops --version
```

If any of those say "not found", **restart Git Bash** so the new PATH entries are picked up. If still not found, the install didn't land on PATH — re-install or fix PATH manually.

### Start Docker Desktop

Launch Docker Desktop and let it finish booting (whale icon stops animating in the tray). The dev stack needs the daemon running before `docker compose up`.

---

## 2. Clone the monorepo + sibling repos

In Git Bash, in your chosen non-synced parent directory:

```bash
cd /c/dev                           # or wherever you picked
git clone <dev-stack-repo-url> appliceo
cd appliceo
bash bin/clone-all.sh
```

`bin/clone-all.sh` clones every sibling repo (`api/`, `ui/`, `docuceo/`, `appliceo-php/`, `lease-config/`, `EtatDesLieux/`, `rapporteur/`, `e2e/`, `appliceo-node/`) as a sibling of the dev-stack and checks each out on its dev branch.

> Each sibling is its own git repo with its own remote. They are **not** submodules — they're independent repos cloned into ignored paths inside the dev-stack tree. Each one's `.gitignore` keeps it from being committed to the dev-stack repo.

---

## 3. Generate your age keypair

```bash
bash bin/secret.sh bootstrap
```

This:
1. Verifies `age` is on PATH.
2. Creates `~/.config/sops/age/keys.txt` (your **private key** — keep it secret).
3. Prints your **public key** to stdout. It looks like `age1abc...verylongstring...xyz`.

Copy the public key line. Send it to the project owner via any private channel (Signal, encrypted email, in-person). They will:

```
bash bin/secret.sh grant <your-name> <your-pubkey> dev
git commit && git push
```

Once that lands on the remote, you can decrypt dev secrets.

### Windows runtime auto-config

`bin/secret.sh` detects Git Bash automatically and:
- passes `--no-fifo` to all sops edit operations (works around a Windows + named-pipe bug that would otherwise hang or give you an empty editor),
- sets `TMPDIR=$USERPROFILE/AppData/Local/sops-tmp` so the brief plaintext window during edit lives on a local-only path, never on OneDrive/Dropbox,
- installs a cleanup trap so stale temp files (>60 min old) get purged on exit.

You don't need to do anything for this. Just always use `bin/secret.sh`, never raw `sops`.

### Configure your editor

`bin/secret.sh edit` opens `$EDITOR` — sops only re-encrypts on save if the editor blocks until close. Pick one and put it in `~/.bashrc`:

```bash
# Pick one:
export EDITOR="notepad"
export EDITOR="code --wait"          # VS Code — --wait is REQUIRED
export EDITOR="notepad++ -multiInst -nosession -noPlugin"
```

Plain `code` without `--wait` returns immediately and sops will think you saved an empty file. Always use `--wait`.

---

## 4. Pull encrypted dev secrets + render configs

After the maintainer grants your pubkey and pushes:

```bash
git pull
bash bin/configure.sh
```

`bin/configure.sh`:
1. Sources `config/defaults.env` + `config/profiles/full-local.env`.
2. Decrypts `config/secrets.dev.sops.yaml` via sops (uses your age key).
3. Renders every rendered file from `config/templates/` — root `.env`, `api/.env`, `docuceo/.env`, `docker/php/gestion-config.php`.
4. Refuses to promote a broken render: each rendered file is verified before replacing the live one (atomic write, `php -l` for PHP, missing-`${VAR}` check) — a partial / broken render leaves the previous good file in place and exits non-zero.

Sanity check:

```bash
bash bin/configure.sh --check
```

Should print `in sync` and exit 0. If it reports `drift`, something on disk diverged from the template — rerun without `--check`.

---

## 5. Start the dev stack

```bash
docker compose up --build
```

First boot is slow (image builds + dependency installs + database seeds). Once it settles:

- PHP (V1): https://localhost:8443/ (Apache + PHP-FPM, MySQL backend)
- Docuceo (Astro SSR): http://localhost:4321/
- API (Fastify): http://localhost:5001/
- PostgreSQL: localhost:5432
- MySQL: localhost:3306

The HTTPS cert on `:8443` is self-signed — accept the browser warning once.

Smoke probes from Git Bash:

```bash
curl -sk -o /dev/null -w 'php   HTTP %{http_code}\n' https://localhost:8443/fr/administration/leases
curl -sk -o /dev/null -w 'astro HTTP %{http_code}\n' http://localhost:4321/
curl -sk -o /dev/null -w 'api   HTTP %{http_code}\n' http://localhost:5001/healthz
```

All three should return non-5xx. The PHP route requires a session (will redirect or 200 depending on auth state) — anything 2xx or 3xx is fine, just not 5xx.

Local test credentials live in the project memory (ask the maintainer if needed). The dev stack auto-logs you in as a test user by default (`DEV_AUTO_LOGIN=true` in the rendered PHP config).

---

## 6. Daily operations

```bash
# Multi-repo overview (branch, ahead/behind, clean/dirty per repo)
bash bin/status.sh

# Pull every sibling repo
bash bin/pull-all.sh

# See what secrets you have access to
bash bin/secret.sh status

# Read dev secrets (decrypt to stdout)
bash bin/secret.sh view dev

# Edit dev secrets (opens $EDITOR; sops re-encrypts on save)
bash bin/secret.sh edit dev

# Rotate a single key (old value moves to KEY_PREVIOUS for verifier overlap)
bash bin/secret.sh rotate JWT_SECRET dev

# Drift-check rendered files against current template+secrets
bash bin/configure.sh --check
```

After any change to `config/templates/`, `config/profiles/*.env`, or sops secrets, re-run `bash bin/configure.sh`. If a container service depends on a rendered file via a bind mount (e.g. `docker/php/gestion-config.php`), restart that container so the mount sees the new file:

```bash
docker compose restart php apache
```

(This is the same restart that recovers from a Docker Desktop bind-mount snapshot getting stuck — see the `ONBOARDING-EXISTING-CLONE.md` troubleshooting section.)

---

## 7. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `sops: command not found` | Install step missed | Re-run section 1; restart Git Bash |
| `Could not decrypt: no master key found` | Pubkey not yet in `.sops.yaml` | Ask maintainer to confirm `grant + push` landed; then `git pull` |
| `sops` opens empty editor / hangs | Running raw `sops <file>` instead of wrapper | Always use `bin/secret.sh edit`; wrapper passes `--no-fifo` on Windows |
| Editor opens but changes don't save | `$EDITOR` doesn't block (e.g. `code` without `--wait`) | Set `EDITOR="code --wait"` and retry |
| `bin/configure.sh` exits 4 / "left untouched" | Template renders invalid PHP or missing `${VAR}` | Read the printed error, fix the template/secret, re-run |
| HMR doesn't fire on docuceo/api file edits | NTFS file-watcher quirk | `CHOKIDAR_USEPOLLING=true` is already set in compose; if using WSL2, set it `false` instead |
| PHP returns HTTP 500 with empty body | Stale `gestion/config.php` view in container (bind mount snapshot stuck) | `docker compose restart php apache` |
| Browser shows cert warning on `:8443` | Self-signed dev cert | Accept once per browser profile |
| Port 8443 / 4321 / 5001 / 3306 / 5432 already in use | Another service grabbed the port | Stop the conflicting process or change the host-side port in `docker-compose.yml` |
| Rendered `.env` ended up empty / partial | Disk error, killed render, etc. | `bin/configure.sh` is idempotent — just re-run it |

---

## 8. What's where

| Path | What |
|---|---|
| `config/templates/*.tmpl` | Source templates rendered by `bin/configure.sh` |
| `config/profiles/*.env` | Per-profile non-secret values (full-local, frontends-only, staging, clever-dev, clever-prod) |
| `config/secrets.dev.sops.yaml` | Encrypted dev secrets (committed) |
| `config/secrets.prod.sops.yaml` | Encrypted prod secrets (gitignored; canonical store is the Clever Cloud env panel) |
| `docker/php/gestion-config.php` | Rendered output for the PHP container (bind-mounted into apache + php) |
| `docker-compose.yml` | Dev stack service definitions |
| `bin/` | All operational scripts (`configure`, `secret`, `clone-all`, `pull-all`, `status`, `check-profiles`, …) |
| `.planning/` | Cross-project plans (gitignored — local working notes) |
| `TODO.md` | Consolidated open-work scoreboard (root, tracked) |
| `e2e/` | Playwright harness (sibling repo, separate; optional for dev stack) |

---

## 9. Done

You should now have:
- Local non-synced clone at `C:\dev\appliceo\` (or equivalent)
- All sibling repos cloned by `bin/clone-all.sh`
- Your age key registered with the project; dev secrets decryptable
- Rendered `.env` + `gestion/config.php` in place
- Dev stack running and reachable on the URLs in section 5

If anything in this guide failed, capture the exact command + exact error in Git Bash and ask the maintainer. Common Windows-specific issues are listed in section 7; everything else is the same on all platforms.
