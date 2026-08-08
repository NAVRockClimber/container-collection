# container-collection

Monorepo for custom multi-arch container images used in the Kubernetes cluster. Each image has its own README with usage details.

> This repo is developed with AI assistance. Code and documentation may be AI-generated.

## Architecture

- **Build**: Docker Buildx with QEMU for cross-platform builds (`linux/amd64`, `linux/arm64`)
- **Lint**: MegaLinter for repo-level lint, Hadolint per image
- **Scan**: Trivy CVE scanning per image
- **Sign**: Cosign keyless signing via GitHub OIDC
- **Update**: Renovate auto-updates base images, upstream releases, and actions

## Images

| Image | Path | Upstream |
|---|---|---|
| [obs-mcp](obs-mcp/) | [`obs-mcp/`](obs-mcp/) | [rhobs/obs-mcp](https://github.com/rhobs/obs-mcp) |

## Usage

### CI/CD

- **PR**: Lint + build (dry-run, no push)
- **Push to main**: Lint + build + push to ghcr.io
- **Workflow dispatch**: Manual build with version override

### Adding a new image

1. Create `<name>/Dockerfile` with `ARG UPSTREAM_REPO`, `ARG UPSTREAM_VERSION`, and `ARG EXPOSE_PORT`
2. Add `test/*.sh` scripts for smoke testing
3. Add `<name>/README.md` (see [obs-mcp/README.md](obs-mcp/README.md) for the template)
4. Update the images table above

No Renovate or workflow changes needed — CI discovers images automatically.

### Conventions

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines and [AGENTS.md](AGENTS.md) for the full convention reference.
