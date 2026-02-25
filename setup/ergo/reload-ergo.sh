#!/bin/bash
# Certbot renewal hook — reloads Ergo after Let's Encrypt cert renewal
# Deploy: cp this file to /etc/letsencrypt/renewal-hooks/deploy/
systemctl reload-or-restart ergo
