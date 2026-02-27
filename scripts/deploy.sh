#!/usr/bin/env bash
set -euo pipefail

# colony deploy script
# Usage:
#   set -a && source .env && set +a && curl -sSL https://raw.githubusercontent.com/PJ-NBA-472915/colony-/main/scripts/deploy.sh | bash

REPO="ghcr.io/${GITHUB_PROJECT}/colony:latest"

# --- Validate required env vars ---
missing=()
for var in SSH_PUBLIC_KEY ZEROTIER_NETWORK GITHUB_PROJECT GITHUB_TOKEN; do
    if [ -z "${!var:-}" ]; then
        missing+=("$var")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "[deploy] ERROR: Missing required variables: ${missing[*]}"
    echo "[deploy] Ensure your .env file contains: SSH_PUBLIC_KEY, ZEROTIER_NETWORK, GITHUB_PROJECT, GITHUB_TOKEN"
    exit 1
fi

# --- Install Docker if not present ---
if ! command -v docker &>/dev/null; then
    echo "[deploy] Docker not found, installing..."
    curl -fsSL https://get.docker.com | sh
    echo "[deploy] Docker installed"
fi

# --- Log in to GHCR ---
echo "[deploy] Logging in to ghcr.io..."
echo "$GITHUB_TOKEN" | docker login ghcr.io -u "${GITHUB_PROJECT%%/*}" --password-stdin

# --- Pull and run ---
echo "[deploy] Pulling ${REPO}..."
docker pull "$REPO"

echo "[deploy] Stopping existing colony container (if any)..."
docker rm -f colony 2>/dev/null || true

echo "[deploy] Starting colony..."
docker run -d \
    --name colony \
    --restart unless-stopped \
    --cap-add NET_ADMIN \
    --device /dev/net/tun:/dev/net/tun \
    -v colony-storage:/storage \
    -v colony-home:/home/colony \
    -e SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" \
    -e ZEROTIER_NETWORK="$ZEROTIER_NETWORK" \
    "$REPO"

echo "[deploy] Colony is running"
docker ps --filter name=colony --format "table {{.ID}}\t{{.Status}}\t{{.Ports}}"
