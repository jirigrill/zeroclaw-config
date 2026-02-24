#!/usr/bin/env bash
# Register IRC accounts on a running Ergo server
# Run on the server after install.sh
set -euo pipefail

NICK="${1:-jiri}"
PASSWORD="${2:-changeme}"

echo "Registering IRC account: ${NICK}"

python3 - "$NICK" "$PASSWORD" << 'PYEOF'
import ssl, socket, time, base64, sys

nick = sys.argv[1]
password = sys.argv[2]

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

with socket.create_connection(("127.0.0.1", 6697), timeout=15) as sock:
    with ctx.wrap_socket(sock, server_hostname="127.0.0.1") as s:
        def send(line):
            s.sendall((line + "\r\n").encode())

        send(f"NICK {nick}_reg")
        send(f"USER {nick}_reg 0 * :registration")
        time.sleep(1.5)
        s.recv(4096)
        send(f"NS REGISTER {password} {nick}@nofiat.me")
        time.sleep(1)
        data = s.recv(4096).decode(errors="ignore")
        if "registered" in data.lower() or "900" in data:
            print(f"Account '{nick}' registered successfully")
        else:
            print(f"Response: {data[:200]}")
        send("QUIT")
PYEOF
