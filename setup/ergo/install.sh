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
sed -i 's|":6697":|"0.0.0.0:6697":|' /etc/ergo/ircd.conf
sed -i "s|cert: fullchain.pem|cert: /etc/letsencrypt/live/irc.nofiat.me/fullchain.pem|" /etc/ergo/ircd.conf
sed -i "s|key: privkey.pem|key: /etc/letsencrypt/live/irc.nofiat.me/privkey.pem|" /etc/ergo/ircd.conf

# Harden: require SASL auth for all connections, disable self-registration
python3 - << 'PYEOF'
with open('/etc/ergo/ircd.conf', 'r') as f:
    content = f.read()
content = content.replace(
    '        # if this is enabled, all clients must authenticate with SASL while connecting.\n        # WARNING: for a private server, you MUST set accounts.registration.enabled\n        # to false as well, in order to prevent non-administrators from registering\n        # accounts.\n        enabled: false',
    '        # if this is enabled, all clients must authenticate with SASL while connecting.\n        # WARNING: for a private server, you MUST set accounts.registration.enabled\n        # to false as well, in order to prevent non-administrators from registering\n        # accounts.\n        enabled: true'
)
with open('/etc/ergo/ircd.conf', 'w') as f:
    f.write(content)
PYEOF
# Line 414: disable open account registration
sed -i '414s/enabled: true/enabled: false/' /etc/ergo/ircd.conf
# Patch: datastore path
sed -i "s|path: ircd.db|path: /var/lib/ergo/ircd.db|" /etc/ergo/ircd.conf

mkdir -p /var/lib/ergo

# Install systemd service
cp "$(dirname "$0")/ergo.service" /etc/systemd/system/ergo.service
systemctl daemon-reload
systemctl enable ergo
systemctl start ergo

echo ""
echo "Ergo running on 0.0.0.0:6697 (TLS, Let's Encrypt cert for irc.nofiat.me)"
echo ""
echo "Next: register IRC accounts and get TLS cert"
echo "  1. Get cert:               certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/.cloudflare.ini -d irc.nofiat.me"
echo "  2. Add renewal hook:       cp setup/ergo/reload-ergo.sh /etc/letsencrypt/renewal-hooks/deploy/"
echo "  3. Register your user:     run setup/ergo/register-accounts.sh"
echo "  4. Add IRC to ZeroClaw:    add [channels_config.irc] to config.toml (see config.example.toml)"
echo "  5. Connect from macOS:     brew install halloy, connect to irc.nofiat.me:6697"
