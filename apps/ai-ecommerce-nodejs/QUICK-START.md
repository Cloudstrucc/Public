# 🚀 Quick Start Guide - AI E-commerce Platform (Node.js)

## ⚡ 30-Second Setup

```bash
# 1. Start the platform
make quick-start

# 2. Wait 2-3 minutes for services to initialize

# 3. Open your browser
open http://localhost:3000
```

## 🎯 What You Get

- **🛍️ Beautiful E-commerce Store**: Modern Next.js frontend with React SSR
- **🤖 AI Product Agent**: Automatically imports products every 15 minutes  
- **💳 Payment Ready**: Stripe integration ready for real transactions
- **📊 Admin Dashboard**: Grafana monitoring at http://localhost:3002
- **🔧 REST API**: Express.js API at http://localhost:3001

## 📱 Access Points

| Service | URL | Description |
|---------|-----|-------------|
| **E-commerce Store** | http://localhost:3000 | Your customer-facing store |
| **API** | http://localhost:3001 | REST API for all operations |
| **Grafana** | http://localhost:3002 | Monitoring (admin/admin123) |
| **Database** | localhost:5432 | PostgreSQL direct access |

## 🔧 Essential Commands

```bash
# View real-time logs
make logs

# Check service health
make health-check

# Add sample products instantly
make populate-products

# Access database
make shell-db

# Backup your data
make backup

# Stop everything
make down
```

## 🤖 AI Agent Status

The Python AI agent runs automatically and:
- ✅ Scrapes products from suppliers
- ✅ Applies intelligent pricing (20% markup)
- ✅ Updates inventory levels
- ✅ Runs every 15 minutes

Watch it work: `make logs-agent`

## 🐛 Quick Fixes

**API won't start?**
```bash
make fix-api
```

**No products showing?**
```bash
make populate-products
```

**M4 Mac issues?**
```bash
make m4-check
```

**Database problems?**
```bash
make db-status
```

## 🎉 Success Indicators

You'll know everything is working when:
- ✅ http://localhost:3000 shows a beautiful store
- ✅ Products appear automatically
- ✅ API responds at http://localhost:3001/health
- ✅ Logs show "AI Agent is Working Hard!"

## 💡 Next Steps

1. **Customize**: Edit frontend in `nextjs-frontend/src/`
2. **Add Features**: Extend API in `express-api/src/`
3. **Go Live**: Update Stripe keys in `.env`
4. **Scale**: Use `docker-compose.prod.yml`

**Need help?** Check the main README.md for full documentation.

---
🎯 **Pro tip**: Run `make health-check` to verify everything is working perfectly!
