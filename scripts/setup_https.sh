#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-controlcalidad360.site}"
EMAIL="${2:-sudoresmaestro@gmail.com}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[HTTPS] Domain: $DOMAIN"
echo "[HTTPS] Email:  $EMAIL"

mkdir -p certbot/www certbot/conf

# Ensure nginx (HTTP) is up for ACME challenge

echo "[HTTPS] Starting nginx/http for ACME challenge..."
docker compose up -d nginx

echo "[HTTPS] Requesting Let's Encrypt certificate..."
docker compose run --rm --no-deps certbot -c "certbot certonly --webroot -w /var/www/certbot -d $DOMAIN -d www.$DOMAIN --email $EMAIL --agree-tos --no-eff-email --rsa-key-size 4096 --non-interactive --expand"

echo "[HTTPS] Activating HTTPS nginx config..."
cp nginx/default-https.conf nginx/default.conf

echo "[HTTPS] Restarting nginx with TLS config..."
docker compose up -d nginx

echo "[HTTPS] Done. Open: https://$DOMAIN"
