# Troubleshooting Guide

## Common Issues and Solutions

### ACA-Py Agent Issues

#### Agent shows "anonymous": true
**Cause**: Agent doesn't have a proper DID
**Solution**: 
1. Check seed configuration (must be exactly 32 characters)
2. Verify genesis URL is accessible
3. Ensure wallet is properly configured

```bash
# Check agent logs
docker-compose logs acapyagent

# Verify genesis endpoint
curl http://localhost:9000/genesis
```

#### Wallet errors
**Cause**: Incorrect wallet type or configuration
**Solution**:
1. Use `askar` wallet type (not `indy`)
2. Ensure auto-provision is enabled
3. Check wallet keys are set

#### Ledger connection errors
**Cause**: Can't connect to von-network
**Solution**:
1. Ensure von-network is running
2. Check docker network connectivity
3. Verify genesis URL in agent configuration

### Von-Network Issues

#### Genesis endpoint not accessible
**Solution**:
```bash
# Check von-network status
cd docker/von-network
docker-compose logs webserver

# Restart if needed
docker-compose down && docker-compose up -d
```

#### Nodes not starting
**Solution**:
```bash
# Check individual node logs
docker-compose logs node1
docker-compose logs node2

# Verify port availability
netstat -tulpn | grep 970
```

### Docker Issues

#### Port conflicts
**Solution**:
```bash
# Find what's using the port
sudo lsof -i :3001

# Kill conflicting process
sudo kill -9 <PID>
```

#### Permission denied
**Solution**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Network Issues

#### Can't connect from mobile wallet
**Solution**:
1. Ensure agent endpoint uses public IP
2. Check firewall rules
3. Verify mediator is running

```bash
# Update endpoints with public IP
PUBLIC_IP=$(curl -s ifconfig.me)
# Update docker-compose.yml endpoints
```

#### API calls fail with 401
**Solution**:
```bash
# Ensure API key is correct
curl -H "X-API-KEY: mysecretkey" http://localhost:3001/status
```

## Diagnostic Commands

```bash
# Check all containers
docker ps

# Check specific service logs
docker-compose logs -f acapyagent

# Test connectivity
curl -v http://localhost:9000/genesis
curl -v -H "X-API-KEY: mysecretkey" http://localhost:3001/status

# Check docker networks
docker network ls
docker network inspect <network-name>
```
