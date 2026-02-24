#!/usr/bin/env bash
# Install Ergo IRC server for ZeroClaw on Ubuntu/Debian
# Run as root on the server
set -euo pipefail

ERGO_VERSION="2.17.0"
ERGO_URL="https://github.com/ergochat/ergo/releases/download/v${ERGO_VERSION}/ergo-${ERGO_VERSION}-linux-x86_64.tar.gz"

echo "Installing Ergo ${ERGO_VERSION}..."

# Download and install binary + language files
cd /tmp
curl -sL "${ERGO_URL}" | tar xz
cp "ergo-${ERGO_VERSION}-linux-x86_64/ergo" /usr/local/bin/ergo
mkdir -p /etc/ergo
cp -r "ergo-${ERGO_VERSION}-linux-x86_64/languages" /etc/ergo/

# Generate self-signed TLS cert (localhost only — accessed via SSH tunnel)
openssl req -x509 -newkey rsa:4096 -keyout /etc/ergo/tls.key -out /etc/ergo/tls.crt \
  -days 3650 -nodes \
  -subj "/CN=localhost" \
  -addext "subjectAltName=IP:127.0.0.1,DNS:localhost" 2>/dev/null

# Write config (patch from ergo defaults)
ergo defaultconfig > /etc/ergo/ircd.conf

# Patch: network name
sed -i "s/name: ErgoTest/name: nofiat/" /etc/ergo/ircd.conf
# Patch: server name
sed -i "s/name: ergo.test/name: nofiat.localhost/" /etc/ergo/ircd.conf
# Patch: localhost TLS only (disable plaintext, restrict TLS to localhost)
sed -i 's|"127.0.0.1:6667": # (loopback ipv4, localhost-only)|#&|' /etc/ergo/ircd.conf
sed -i 's|"\[::1\]:6667":     # (loopback ipv6, localhost-only)|#&|' /etc/ergo/ircd.conf
sed -i 's|":6697":|"127.0.0.1:6697":|' /etc/ergo/ircd.conf
sed -i "s|cert: fullchain.pem|cert: /etc/ergo/tls.crt|" /etc/ergo/ircd.conf
sed -i "s|key: privkey.pem|key: /etc/ergo/tls.key|" /etc/ergo/ircd.conf
# Patch: datastore path
sed -i "s|path: ircd.db|path: /var/lib/ergo/ircd.db|" /etc/ergo/ircd.conf

mkdir -p /var/lib/ergo

# Install systemd service
cp "$(dirname "$0")/ergo.service" /etc/systemd/system/ergo.service
systemctl daemon-reload
systemctl enable ergo
systemctl start ergo

echo ""
echo "Ergo running on 127.0.0.1:6697 (TLS, localhost only)"
echo ""
echo "Next: register IRC accounts"
echo "  1. Register your user:     run setup/ergo/register-accounts.sh"
echo "  2. Add IRC to ZeroClaw:    add [channels_config.irc] to config.toml (see config.example.toml)"
echo "  3. Connect from macOS:     brew install halloy, then SSH tunnel:"
echo "     ssh -N -L 6697:127.0.0.1:6697 nofiat-droplet"
echo "     Connect Halloy to 127.0.0.1:6697, disable cert verification"
