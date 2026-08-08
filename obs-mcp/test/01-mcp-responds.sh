#!/bin/sh
# Smoke test: verify MCP server responds
set -e

response=$(curl -sf -X POST "http://$1:$2/mcp" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}')

echo "$response" | grep -q '"result"'
echo "MCP tools/list OK"
