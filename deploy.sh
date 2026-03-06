#!/usr/bin/env bash
# Smart deploy for docker-compose + git flow
# - Pulls latest changes with fast-forward only
# - Rebuilds app container only when needed
# - Avoids manual "docker compose restart app" on every deploy

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

BRANCH_ARG="${1:-}"
FORCE_DIRTY="${FORCE_DIRTY:-0}"
ALLOWED_DIRTY_REGEX="${ALLOWED_DIRTY_REGEX:-^(\.env|catalogo_app\.log|uploads/productos/|certbot/www/|certbot/conf/|nginx/default\.conf)}"

log() {
  printf "\n[%s] %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$*"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: Command not found: $1"
    exit 1
  fi
}

contains_line() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

require_cmd git
require_cmd docker

wait_for_app_ready() {
  local timeout_secs="${1:-180}"
  local interval_secs=3
  local elapsed=0

  log "Waiting for app container readiness (timeout: ${timeout_secs}s)"

  while (( elapsed < timeout_secs )); do
    local app_id
    app_id="$(docker compose ps -q app 2>/dev/null || true)"

    if [[ -n "$app_id" ]]; then
      local running health
      running="$(docker inspect -f '{{.State.Running}}' "$app_id" 2>/dev/null || echo false)"
      health="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$app_id" 2>/dev/null || echo unknown)"

      if [[ "$running" == "true" ]]; then
        if [[ "$health" == "healthy" || "$health" == "none" ]]; then
          log "App is ready (running=$running, health=$health)."
          return 0
        fi
      fi
    fi

    sleep "$interval_secs"
    elapsed=$((elapsed + interval_secs))
  done

  echo "ERROR: App did not become ready within ${timeout_secs}s."
  docker compose ps
  docker compose logs --tail=120 app || true
  return 1
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: This script must run inside a git repository."
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose is not available."
  exit 1
fi

DIRTY_STATUS="$(git status --porcelain)"
if [[ "$FORCE_DIRTY" != "1" ]] && [[ -n "$DIRTY_STATUS" ]]; then
  mapfile -t DIRTY_LINES <<< "$DIRTY_STATUS"
  DISALLOWED_DIRTY=()
  ALLOWED_DIRTY=()

  for line in "${DIRTY_LINES[@]}"; do
    entry="${line:3}"
    entry="${entry## }"
    # Manejar renombres: "old -> new"
    path="${entry##* -> }"

    if [[ "$path" =~ $ALLOWED_DIRTY_REGEX ]]; then
      ALLOWED_DIRTY+=("$line")
    else
      DISALLOWED_DIRTY+=("$line")
    fi
  done

  if [[ ${#DISALLOWED_DIRTY[@]} -gt 0 ]]; then
    echo "ERROR: Working tree has local changes not allowed for auto-deploy:"
    printf '  - %s\n' "${DISALLOWED_DIRTY[@]}"
    echo "Commit/stash those changes, or run with FORCE_DIRTY=1 to override."
    exit 1
  fi

  log "Detected only allowed runtime local changes. Continuing deploy."
  printf '  - %s\n' "${ALLOWED_DIRTY[@]}"
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
TARGET_BRANCH="$CURRENT_BRANCH"
if [[ -n "$BRANCH_ARG" ]]; then
  TARGET_BRANCH="$BRANCH_ARG"
fi

log "Branch: $CURRENT_BRANCH (target: $TARGET_BRANCH)"

if [[ "$TARGET_BRANCH" != "$CURRENT_BRANCH" ]]; then
  log "Checking out target branch: $TARGET_BRANCH"
  git checkout "$TARGET_BRANCH"
fi

BEFORE_SHA="$(git rev-parse HEAD)"

log "Fetching remote updates"
git fetch --all --prune

log "Pulling latest changes (fast-forward only)"
git pull --ff-only

AFTER_SHA="$(git rev-parse HEAD)"

if [[ "$BEFORE_SHA" == "$AFTER_SHA" ]]; then
  log "No new commits. Nothing to deploy."
  exit 0
fi

log "Updated commit: ${BEFORE_SHA:0:8} -> ${AFTER_SHA:0:8}"

mapfile -t CHANGED_FILES < <(git diff --name-only "$BEFORE_SHA" "$AFTER_SHA")

if [[ ${#CHANGED_FILES[@]} -eq 0 ]]; then
  log "No changed files detected between commits."
  exit 0
fi

log "Changed files:"
printf '  - %s\n' "${CHANGED_FILES[@]}"

NEED_REBUILD=0
NEED_COMPOSE_APPLY=0
NEED_NGINX_RELOAD=0
NEED_APP_RESTART=0

for f in "${CHANGED_FILES[@]}"; do
  case "$f" in
    Dockerfile|requirements.txt|pyproject.toml|poetry.lock)
      NEED_REBUILD=1
      ;;
    docker-compose.yml)
      NEED_COMPOSE_APPLY=1
      ;;
    nginx/default.conf|nginx/default-https.conf)
      NEED_NGINX_RELOAD=1
      ;;
    *.py|templates/*|static/*)
      NEED_APP_RESTART=1
      ;;
  esac
done

if [[ "$NEED_REBUILD" -eq 1 ]]; then
  log "Dependency/build file changed. Rebuilding app image and recreating app container."
  docker compose up -d --build app
elif [[ "$NEED_COMPOSE_APPLY" -eq 1 ]]; then
  log "Compose file changed. Applying compose changes."
  docker compose up -d --remove-orphans
elif [[ "$NEED_APP_RESTART" -eq 1 ]]; then
  log "Application files changed. Restarting app container for consistent version on first request."
  docker compose restart app
  sleep 2
else
  log "No app-level changes detected. Skipping app restart."
fi

if [[ "$NEED_NGINX_RELOAD" -eq 1 ]]; then
  log "Nginx config changed. Reloading nginx."
  docker compose exec -T nginx nginx -s reload || docker compose restart nginx
fi

if [[ "$NEED_REBUILD" -eq 1 || "$NEED_COMPOSE_APPLY" -eq 1 || "$NEED_APP_RESTART" -eq 1 ]]; then
  wait_for_app_ready 180
fi

log "Service status"
docker compose ps

log "Deploy completed successfully"
