# obs-mcp

[![Upstream Release](https://img.shields.io/github/v/release/rhobs/obs-mcp?label=upstream)](https://github.com/rhobs/obs-mcp/releases)
[![Container Image](https://img.shields.io/badge/ghcr.io-navrockclimber%2Fobs--mcp-blue)](https://github.com/NAVRockClimber/container-collection/pkgs/container/obs-mcp)
[![Upstream License](https://img.shields.io/github/license/rhobs/obs-mcp)](https://github.com/rhobs/obs-mcp/blob/main/LICENSE)

Observability MCP server — exposes Prometheus, AlertManager, and Loki as MCP tools. Built from [rhobs/obs-mcp](https://github.com/rhobs/obs-mcp). See [upstream docs](https://github.com/rhobs/obs-mcp) for full configuration details.

## Usage

```
docker run -p 8080:8080 ghcr.io/navrockclimber/obs-mcp:0.7.1-alpine3.24
```

### Quick reference

| What | Details |
|------|---------|
| Port | 8080 (MCP server) |
| Environment | `PROMETHEUS_URL`, `ALERTMANAGER_URL`, `LOKI_URL` |
| Flags | `--listen` (default `:8080`), `--auth-mode` |
| Entrypoint | `/usr/local/bin/obs-mcp` |

For full configuration, see the [upstream documentation](https://github.com/rhobs/obs-mcp).

## Tags

Tags follow `<upstream-version>-<base><base-version>`. No `latest` tag.

| Tag | Upstream | Base |
|-----|----------|------|
| `0.7.1-alpine3.24` | obs-mcp 0.7.1 | Alpine 3.24 |
