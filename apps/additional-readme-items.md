Great progress! The Docker Compose version issue has been resolved, and the von-network started successfully. However, the ACA-Py agents (main agent and mediator) are not responding. Let's troubleshoot this step by step.

## Current Status Analysis

✅ **Working:**
- Von-network (Hyperledger Indy Ledger) is running correctly
- Docker Compose version issue resolved
- Genesis endpoint is available

❌ **Issues:**
- ACA-Py main agent is not responding
- Mediator is not responding
- Container status check isn't showing running containers

## Troubleshooting Steps

### 1. Check Container Status
```bash
cd ~/aries-canada-
docker ps -a
```

### 2. Check ACA-Py Logs
```bash
cd ~/aries-canada-/docker/aca-py
docker-compose logs agent
echo "--- MEDIATOR LOGS ---"
docker-compose logs mediator
```

### 3. Check Network Connectivity
```bash
# Check if containers can reach von-network
docker network ls
docker network inspect aries-network
docker network inspect von-network_von
```

### 4. Test Von-Network Connection
```bash
# Test the genesis endpoint that agents need
curl http://localhost:9000/genesis
curl http://localhost:9000/status
```

### 5. Check Resource Usage
```bash
# Check if the VM has enough resources
free -h
df -h
docker system df
```

## Common Issues and Solutions

**If containers are failing to start:**
```bash
# Check for port conflicts
sudo netstat -tulpn | grep -E ":(3001|3003|8000|8001)"

# Check Docker daemon
sudo systemctl status docker
```

**If containers are crashing:**
```bash
# Check for memory/resource issues
dmesg | tail -20
```

**If there are network connectivity issues:**
```bash
# Recreate networks
cd ~/aries-canada-/docker/aca-py
docker-compose down
docker network prune -f
docker-compose up -d
```

## Quick Fix Attempt

Try restarting just the ACA-Py components:
```bash
cd ~/aries-canada-
./scripts/stop-aries-stack.sh
sleep 10
./scripts/start-aries-stack.sh
```

## Check Configuration Files

Let's also verify the ACA-Py configuration:
```bash
cd ~/aries-canada-/docker/aca-py
cat docker-compose.yml | head -20
ls -la
```

Run the troubleshooting commands above and paste the output. The logs from the ACA-Py containers will be particularly helpful in identifying why the agents aren't starting properly.

**Most likely causes:**
1. **Configuration mismatch** - Genesis URL or ledger connection issues
2. **Resource constraints** - Not enough memory/CPU
3. **Network connectivity** - Containers can't reach each other or von-network
4. **Port conflicts** - Something else using the required ports

Let me know what you find in the logs and container status!