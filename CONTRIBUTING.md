# Contributing

## About this repo

> This repository is developed with heavy AI assistance. Code and documentation may be AI-generated. Review before trusting. If you're an AI agent, start with [AGENTS.md](AGENTS.md).

## Setup

You need:

- [Docker](https://docs.docker.com/engine/install/)
- [Docker Buildx](https://docs.docker.com/build/install-buildx/)
- [QEMU](https://docs.docker.com/build/building/multi-platform/#qemu) (for cross-platform builds)

```sh
git clone https://github.com/NAVRockClimber/container-collection.git
cd container-collection
docker buildx create --use   # if not already set up
```

## Adding a new image

1. Open an issue using the **New image proposal** template — this ensures discussion before code
2. Create a directory with a `Dockerfile` using the required ARGs (see [AGENTS.md](AGENTS.md) for the full convention reference)
3. Add smoke test scripts in `test/` — each gets `<host>` and `<port>` as `$1` and `$2`
4. Add a `README.md` (see [obs-mcp/README.md](obs-mcp/README.md) for the template)
5. Update the images table in [README.md](README.md)
6. Open a PR — CI will auto-discover the new image

CI discovers images automatically — no workflow or Renovate changes needed.

## CI checks

Every PR runs:

| Check | What it does | Blocks PR? |
|-------|-------------|------------|
| MegaLinter | YAML, shell, Markdown lint | No |
| Hadolint | Dockerfile best practices | On error |
| License | Upstream license compatibility | On GPL/AGPL |
| Trivy | CVE scan | On HIGH + CRITICAL |
| Smoke test | Your `test/*.sh` scripts | On failure |

All checks run per image independently — a failure in one image doesn't stop others.

## AI-generated contributions

PRs that appear to be fully AI-generated without evidence of local testing (no smoke test output, no verified build, no explanation of what was checked) will be closed without review. Repeated submissions may lead to a ban.

If you use AI to help, that's fine — just include what you tested and how.

## Conventions

The full convention reference lives in [AGENTS.md](AGENTS.md). Quick summary:

- Dockerfile requires `ARG UPSTREAM_REPO`, `ARG UPSTREAM_VERSION`, `ARG EXPOSE_PORT`
- Tags: `<upstream-version>-<base-name><base-version>` (e.g. `0.7.1-alpine3.24`)
- No mutable tags (`latest`, `main`)
- Multi-arch (`linux/amd64`, `linux/arm64`) is mandatory
- Alpine base images only (for now)
