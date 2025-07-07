#!/bin/bash

echo "🔧 Fixing ARM64 compatibility..."

# Update von-network docker-compose.yml
cat > docker/von-network/docker-compose.yml << 'COMPOSE_EOF'
version: '3.8'
services:
  webserver:
    image: ghcr.io/bcgov/von-network-base:latest
    platform: linux/amd64  # Force x86_64 emulation
    container_name: von-webserver
    command: bash -c 'sleep 10 && ./scripts/start_webserver.sh -i ${IP:-0.0.0.0}'
    environment:
      - IP=0.0.0.0
      - IPS=
      - DOCKERHOST=host.docker.internal
      - LOG_LEVEL=INFO
      - RUST_LOG=warning
      - GENESIS_URL=
      - LEDGER_SEED=
      - LEDGER_CACHE_PATH=
      - REGISTER_NEW_DIDS=True
      - ENABLE_LEDGER_CACHE=True
      - ENABLE_BROWSER_ROUTES=True
      - DISPLAY_LEDGER_STATE=True
      - LEDGER_INSTANCE_NAME=von-network
      - LEDGER_DESCRIPTION=Von Network Local Ledger
    networks:
      - von
    ports:
      - "9000:8000"
    volumes:
      - webserver-cli:/home/indy/.indy-cli
      - webserver-ledger:/home/indy/ledger

  node1:
    image: ghcr.io/bcgov/von-network-base:latest
    platform: linux/amd64
    container_name: von-node1
    command: ./scripts/start_node.sh 1
    networks:
      - von
    ports:
      - "9701:9701"
      - "9702:9702"
    environment:
      - IP=0.0.0.0
      - IPS=
      - DOCKERHOST=host.docker.internal
      - LOG_LEVEL=INFO
      - RUST_LOG=warning
    volumes:
      - node1-data:/home/indy/ledger

  node2:
    image: ghcr.io/bcgov/von-network-base:latest
    platform: linux/amd64
    container_name: von-node2
    command: ./scripts/start_node.sh 2
    networks:
      - von
    ports:
      - "9703:9703"
      - "9704:9704"
    environment:
      - IP=0.0.0.0
      - IPS=
      - DOCKERHOST=host.docker.internal
      - LOG_LEVEL=INFO
      - RUST_LOG=warning
    volumes:
      - node2-data:/home/indy/ledger

  node3:
    image: ghcr.io/bcgov/von-network-base:latest
    platform: linux/amd64
    container_name: von-node3
    command: ./scripts/start_node.sh 3
    networks:
      - von
    ports:
      - "9705:9705"
      - "9706:9706"
    environment:
      - IP=0.0.0.0
      - IPS=
      - DOCKERHOST=host.docker.internal
      - LOG_LEVEL=INFO
      - RUST_LOG=warning
    volumes:
      - node3-data:/home/indy/ledger

  node4:
    image: ghcr.io/bcgov/von-network-base:latest
    platform: linux/amd64
    container_name: von-node4
    command: ./scripts/start_node.sh 4
    networks:
      - von
    ports:
      - "9707:9707"
      - "9708:9708"
    environment:
      - IP=0.0.0.0
      - IPS=
      - DOCKERHOST=host.docker.internal
      - LOG_LEVEL=INFO
      - RUST_LOG=warning
    volumes:
      - node4-data:/home/indy/ledger

networks:
  von:

volumes:
  webserver-cli:
  webserver-ledger:
  node1-data:
  node2-data:
  node3-data:
  node4-data:
COMPOSE_EOF

echo "✅ Fixed for ARM64! Now try: ./scripts/start-aries-stack.sh"
