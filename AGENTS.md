# Agents

This file is the canonical source of truth for AI agents working on this repo. Conventions documented here are authoritative; CONTRIBUTING.md summarizes them for humans.

## Architecture

### CI/CD pipeline

```
MegaLinter (repo-level lint, non-blocking)
  │
  ▼
discover-images (pre-job) — .github/scripts/discover-images.sh
  │  auto-discovers all top-level directories containing a Dockerfile
  │  reads ARG EXPOSE_PORT from each
  │  outputs JSON: {"image": [{"name": "...", "port": "...", "dir": "..."}]}
  │
  ▼
build matrix (per image, parallel, independent failures)
  │
  ├─ Hadolint lint        — blocks on error-level
  ├─ License check         — blocks on GPL/AGPL, warns on unlicensed
  ├─ Trivy CVE scan        — blocks on HIGH + CRITICAL
  ├─ Build (amd64, load)
  ├─ Health check          — HEALTHCHECK → docker inspect; fallback: curl-poll EXPOSE_PORT
  ├─ Smoke test            — test/*.sh scripts, alphabetical, each gets <host> <port>
  ├─ Build multi-arch      — linux/amd64 + linux/arm64 via Buildx --platform
  └─ Push                  — only on main branch
```

Multi-arch is a single Buildx command (no nested matrix). Each matrix leg fails independently — a CVE in one image does not block other images.

### File layout

```
/
├── <image-name>/          # one directory per image
│   ├── Dockerfile         # required — triggers auto-discovery
│   ├── README.md          # required — per-image documentation
│   └── test/              # optional — smoke test scripts
│       └── *.sh           # alphabetical, exits 0 on pass
├── .github/
│   ├── workflows/         # CI pipeline
│   └── scripts/           # CI helper scripts (discover-images.sh, etc.)
├── AGENTS.md              # this file
├── CONTRIBUTING.md        # human contributor guide
├── README.md              # project overview (hobbyist audience)
├── renovate.json          # Renovate bot config
└── LICENSE                # Apache-2.0
```

## Domain glossary

| Term | Meaning |
|------|---------|
| **Image** | A container image built and published by this repo. Lives in a top-level directory with a `Dockerfile`. |
| **Image directory** | A top-level directory containing a `Dockerfile`. Auto-discovered by CI. |
| **Upstream** | The third-party software packaged in an image. Referenced via `ARG UPSTREAM_REPO` (GitHub `owner/repo`) and `ARG UPSTREAM_VERSION` (semver string). |
| **Base image** | The `FROM` image in a Dockerfile. Currently always Alpine. |
| **Smoke test** | Scripts in `test/*.sh` that validate a built image starts correctly. Run in CI before push. |
| **Registry** | `ghcr.io` — where built images are published as `ghcr.io/navrockclimber/<image-name>`. |
| **MegaLinter** | Repo-level linter (YAML, shell, Markdown). Non-blocking — failures do not stop the matrix. |
| **Renovate** | Dependency bot. Auto-updates Docker base images, upstream releases (via ARG convention), and GitHub Actions. |

## Conventions

### Dockerfile

Every image's Dockerfile must declare these at the top, before the first `FROM`:

```dockerfile
ARG ALPINE_VERSION=3.24
ARG UPSTREAM_REPO=owner/repo
ARG UPSTREAM_VERSION=X.Y.Z
ARG EXPOSE_PORT=8080
```

- `UPSTREAM_REPO` — GitHub `owner/repo` the binary is downloaded from. Used by Renovate and the license check.
- `UPSTREAM_VERSION` — semver of the upstream release. Tracked by Renovate.
- `EXPOSE_PORT` — port the container listens on. Used by CI smoke tests and health checks.
- `ALPINE_VERSION` — Alpine base image version. Tracked by Renovate's `dockerfile` manager.
- Always declare `ARG` inside each `FROM` stage that uses the variable (for build-time scope).

### Tag format

`<upstream-version>-<base-name><base-version>`

Example: `0.7.1-alpine3.24`

- No mutable tags (`latest`, `main`). Only versioned tags are pushed.
- Base part uses no dash between name and version (`alpine3.24`, not `alpine-3.24`).

### Smoke tests

Scripts in `<image>/test/` run in alphabetical order. Each receives `<host>` and `<port>` as `$1` and `$2`. First script that exits non-zero fails the smoke test for that image.

Example:
```bash
#!/bin/sh
# test/01-health-check.sh
curl -sf "http://$1:$2/health" || exit 1
```

### Renovate

Renovate uses a single `custom.regex` manager with `matchStringsStrategy: "combination"` that matches every Dockerfile:

```json
{
  "managerFilePatterns": ["**/Dockerfile", "**/Containerfile"],
  "matchStringsStrategy": "combination",
  "matchStrings": [
    "ARG UPSTREAM_REPO=(?<depName>\\S+)",
    "ARG UPSTREAM_VERSION=(?<currentValue>\\d+\\.\\d+\\.\\d+)"
  ],
  "datasourceTemplate": "github-releases"
}
```

Adding a new image requires **zero Renovate changes**. The regex covers all Dockerfiles automatically.

### License compliance

CI probes `https://api.github.com/repos/<owner>/<repo>/license` per image using `UPSTREAM_REPO`.

| Upstream license | CI action |
|-----------------|-----------|
| MIT, BSD-2, BSD-3, Apache-2.0, ISC, MPL-2.0 | Pass |
| GPL-2.0, GPL-3.0, AGPL-3.0 | Block build |
| None (unlicensed) | Warn, continue |

## How to add a new image

1. Create `<name>/Dockerfile` with the required ARGs
2. Create `<name>/test/*.sh` smoke test scripts (at least one)
3. Create `<name>/README.md` following the per-image README template
4. Open a proposal issue using the new-image template
5. Once accepted, open a PR adding the new directory
6. Update `README.md` images table

No Renovate changes needed. No workflow changes needed. CI auto-discovers the new directory.

## Documentation conventions

### Per-image README

Template shape (see `obs-mcp/README.md` for the reference implementation):

1. **Title** — binary name
2. **Badges** — upstream release, container image, upstream license
3. **Description** — one paragraph. What it is, what upstream it wraps, link to upstream docs
4. **Usage** — `docker run` command
5. **Quick reference table** — ports, environment variables, flags, entrypoint (overview only, details go upstream)
6. **Tags table** — available tags with upstream and base versions

Principle: lean. Details belong to upstream documentation. The per-image README is a quick-start, not a replacement.

### AI-assisted writing

All documentation in this repo is AI-generated. When writing documentation for a new image:

- Use `UPSTREAM_REPO` to pull the upstream README and docs for factual accuracy
- Verify version numbers are current (ARG values in the Dockerfile)
- Keep the quick-reference table short — 5 rows max, link to upstream for details
- Include the upstream license badge (resolve via GitHub API)
