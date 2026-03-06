#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

mkdir -p certbot/www certbot/conf

echo "[HTTPS] Renewing certificates..."
docker compose run --rm --no-deps certbot -c "certbot renew --webroot -w /var/www/certbot"

echo "[HTTPS] Reloading nginx..."
docker compose exec -T nginx nginx -s reload || docker compose restart nginx

echo "[HTTPS] Renewal complete."
