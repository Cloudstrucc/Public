#!/bin/bash
sudo apt update && sudo apt install -y certbot
sudo certbot certonly --standalone -d agent.yourdomain.ca -d mediator.yourdomain.ca
echo "TLS certificates installed in /etc/letsencrypt/live/."
