# container-collection

Monorepo for custom multi-arch container images used in the Kubernetes cluster.

## Architecture

- **Build**: Docker Buildx with QEMU for cross-platform builds
- **Lint**: MegaLinter (Hadolint, YAML, shell, Markdown)
- **Sign**: Cosign keyless signing via GitHub OIDC
- **Update**: Renovate auto-updates base images, binaries, and actions

## Images

| Image | Path | Source | Version |
|---|---|---|---|
| [`ghcr.io/navrockclimber/obs-mcp`](https://github.com/NAVRockClimber/container-collection/pkgs/container/obs-mcp) | [`obs-mcp/`](obs-mcp/) | [rhobs/obs-mcp](https://github.com/rhobs/obs-mcp) | `0.7.1` |

## Usage

### CI/CD

- **PR**: Lint + build (dry-run, no push)
- **Push to main**: Lint + build + push to ghcr.io
- **Workflow dispatch**: Manual build with version override

### Adding a new image

1. Create `<name>/Dockerfile`
2. Add ARG-based version parameters at the top
3. Add a `customManagers` entry in `renovate.json` for binary tracking
4. Update this README's image table

### Renovate

Renovate watches:
- `FROM alpine:X` in Dockerfiles → new Alpine releases
- `ARG *_VERSION=X.Y.Z` in Dockerfiles → upstream GitHub releases
- GitHub Actions versions in workflows
- Renovate self-updates

Auto-merge is enabled for patch and minor updates that pass CI smoke tests.

### Smoke Tests

Every CI build runs a `tools/list` MCP JSON-RPC call against the built image to verify:
- Binary starts correctly
- MCP protocol responds
- Expected tools are registered
