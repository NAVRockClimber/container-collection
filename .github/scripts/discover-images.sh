#!/bin/sh
set -e

default_port=8080
items=""

for dir in */; do
  dockerfile="${dir}Dockerfile"
  [ -f "$dockerfile" ] || continue

  name="${dir%/}"
  port=$(grep -oP 'ARG EXPOSE_PORT=\K\d+' "$dockerfile" 2>/dev/null || echo "$default_port")

  [ -n "$items" ] && items="$items,"
  items="$items{\"name\":\"$name\",\"port\":\"$port\",\"dir\":\"$name\"}"
done

printf '{"image":[%s]}\n' "$items"
