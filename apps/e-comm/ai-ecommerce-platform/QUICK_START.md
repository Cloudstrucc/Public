# 🚀 Quick Start Guide

## Immediate Next Steps

### 1. Configure Environment
```bash
cp .env.example .env
# Edit .env with your API keys
```

### 2. Start Platform
```bash
# Quick development setup
make quick-start

# Or manual setup
make setup
make dev
```

### 3. Access Your Platform
- **Frontend**: http://localhost:5000
- **API Docs**: http://localhost:7001/swagger
- **Monitoring**: http://localhost:3000

## Required API Keys

### Stripe (Required for payments)
1. Create account at https://stripe.com
2. Get test keys from Dashboard > Developers > API keys
3. Add to .env file

### Power Apps (Optional - for CRM)
1. Go to https://make.powerapps.com
2. Create environment and register app
3. Get credentials from Azure AD
4. Add to .env file

## Common Commands
- `make dev` - Start development environment
- `make logs` - View application logs
- `make status` - Check service status
- `make help` - See all commands

## Troubleshooting
- Verify Docker is running
- Ensure ports 5000, 7001 are available
- Check .env file configuration
- Review logs with `make logs`

Happy coding! 🎉
