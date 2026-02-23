#!/usr/bin/env bash
set -euo pipefail

# Deploy ZeroClaw config to production server
# Usage: ./deploy.sh [host]

HOST="${1:-164.92.236.31}"
REMOTE_HOME="/home/zeroclaw/.zeroclaw"
REMOTE_WORKSPACE="${REMOTE_HOME}/workspace"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Deploying to ${HOST}..."

# Copy identity and skills
scp "${SCRIPT_DIR}/IDENTITY.md" "root@${HOST}:${REMOTE_WORKSPACE}/IDENTITY.md"
scp "${SCRIPT_DIR}"/skills/*.md "root@${HOST}:${REMOTE_WORKSPACE}/skills/"

# Remove old skill files that no longer exist locally
ssh "root@${HOST}" bash -s <<'REMOTE'
cd /home/zeroclaw/.zeroclaw/workspace/skills
for f in *.md; do
    [ -f "$f" ] || continue
    echo "  checking $f"
done
# Clean up known old files
rm -f bitcoin-research.md research-coordinator.md saas-research.md
chown -R zeroclaw:zeroclaw /home/zeroclaw/.zeroclaw/
REMOTE

echo ""
echo "Files deployed. Restarting zeroclaw service..."
ssh "root@${HOST}" "systemctl restart zeroclaw"

echo ""
echo "Done. Checking service status..."
ssh "root@${HOST}" "systemctl is-active zeroclaw"

echo ""
echo "NOTE: If you changed model routes in config.example.toml, you need to"
echo "manually update the live config:"
echo "  ssh root@${HOST} nano ${REMOTE_HOME}/config.toml"
