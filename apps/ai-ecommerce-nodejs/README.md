# 🤖 Complete AI-Powered E-commerce Platform (Node.js + Next.js + Express.js)

A comprehensive, production-ready e-commerce platform powered by artificial intelligence for automated product sourcing, intelligent pricing, and market research. Built with modern Node.js stack and optimized for M4 Mac and Canadian market.

## ✨ Features

- 🤖 **AI-Powered Product Sourcing**: Automated product discovery and import
- ⚡ **Next.js Frontend**: React with Server-Side Rendering for optimal performance
- 🚀 **Express.js API**: Fast, scalable Node.js backend with TypeScript
- 🐘 **PostgreSQL + Prisma**: Modern database with type-safe ORM
- 💳 **Stripe Integration**: Complete payment processing (ready for real payments)
- 🔐 **JWT Authentication**: Secure user authentication and session management
- 🇨🇦 **Canadian Market Focus**: Optimized for Canadian entrepreneurs
- 📊 **Monitoring & Analytics**: Grafana dashboards and Prometheus metrics
- 🐳 **Docker Compose**: One-command deployment with M4 Mac optimization

## 🚀 Quick Start (M4 Mac Optimized)

```bash
# Clone or create the project
mkdir ai-ecommerce-nodejs && cd ai-ecommerce-nodejs

# Run the generator script
chmod +x generate-platform.sh
./generate-platform.sh

# Start the platform
make quick-start

# Access your beautiful e-commerce store
open http://localhost:3000
```

## 📱 Access Your Platform

- 🛍️ **E-commerce Store**: http://localhost:3000 (Next.js with React SSR)
- 🔧 **API**: http://localhost:3001
- 📊 **Grafana Monitoring**: http://localhost:3002 (admin/admin123)
- 🐘 **PostgreSQL**: localhost:5432

## 🎯 Technology Stack

### Frontend
- **Next.js 14**: React framework with Server-Side Rendering
- **TypeScript**: Type-safe JavaScript
- **Tailwind CSS**: Utility-first CSS framework
- **React Hooks**: Modern React state management

### Backend
- **Express.js**: Fast, minimalist Node.js framework
- **TypeScript**: Type-safe server development
- **Prisma**: Modern database toolkit and ORM
- **PostgreSQL**: Advanced open-source database
- **Redis**: In-memory data store for caching
- **JWT**: JSON Web Token authentication

### AI Agent
- **Python**: AI agent for product scraping
- **AsyncIO**: Asynchronous programming
- **PostgreSQL**: Database integration

### DevOps
- **Docker Compose**: Container orchestration
- **ARM64**: M4 Mac optimized images
- **Prometheus**: Metrics collection
- **Grafana**: Monitoring dashboards

## 🔧 Management Commands

```bash
# Development
make dev                 # Start all services
make logs               # View all logs
make logs-api           # View Express.js API logs
make logs-frontend      # View Next.js frontend logs
make logs-agent         # View AI agent logs
make health-check       # Check service health

# Database
make shell-db           # Access PostgreSQL shell
make backup             # Backup PostgreSQL database
make restore BACKUP_FILE=filename  # Restore database

# Maintenance
make restart            # Restart all services
make clean              # Remove all containers and data
make update             # Update all Docker images

# Development
make shell-api          # Access Express.js container
make shell-frontend     # Access Next.js container
make install-deps       # Install all dependencies
```

## 🤖 AI Agent Features

The Python AI agent automatically:
- Scrapes products from supplier websites
- Applies intelligent pricing strategies (20% markup)
- Conducts market research
- Updates inventory levels
- Monitors competitor prices
- Imports data to PostgreSQL via Express.js API

## 💳 Payment Processing

Stripe integration is ready for production:
1. Update your `.env` file with real Stripe keys
2. Configure webhook endpoints
3. Test with Stripe's test cards
4. Go live with real payments

## 🐘 Database Features

PostgreSQL + Prisma setup includes:
- User management with JWT authentication
- Product catalog with JSON fields for flexibility
- Order processing and tracking
- Type-safe database operations
- Automatic migrations
- Performance optimizations for M4 Mac

## 📊 Monitoring

Built-in monitoring includes:
- Application metrics via Prometheus
- Visual dashboards via Grafana
- Health checks for all services
- Log aggregation
- Performance monitoring
- Real-time service status

## 🔒 Security Features

- JWT authentication with secure tokens
- Password hashing with bcrypt
- CORS configuration
- Rate limiting on API endpoints
- Environment variable protection
- Input validation with Zod schemas
- Helmet.js security headers

## 🚀 Production Deployment

```bash
# For production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Or use the production command
make prod
```

## 📝 Environment Configuration

Copy `.env.example` to `.env` and configure:

```env
# Required for payments
STRIPE_SECRET_KEY=sk_live_your_key_here
STRIPE_PUBLISHABLE_KEY=pk_live_your_key_here

# Database (automatically configured)
DATABASE_URL="postgresql://postgres:password@postgres:5432/EcommerceAI?schema=public"

# Security
JWT_SECRET=your-super-secret-key-here
SESSION_SECRET=your-session-secret-here
```

## 🐛 Troubleshooting

### M4 Mac Specific Issues
```bash
# Check platform compatibility
docker info | grep Architecture

# If services fail to start
docker-compose down
docker system prune -f
make dev
```

### Database Issues
```bash
# Reset database (WARNING: deletes all data)
make reset-db

# Check database connection
make shell-db
```

### Node.js Issues
```bash
# Reinstall dependencies
make install-deps

# Check API logs
make logs-api

# Check frontend logs
make logs-frontend
```

### AI Agent Issues
```bash
# Check agent logs
make logs-agent

# Restart just the agent
docker-compose restart python-agent
```

## 📋 Project Structure

```
ai-ecommerce-nodejs/
├── express-api/              # Express.js API with TypeScript
│   ├── src/
│   │   ├── controllers/      # API controllers
│   │   ├── routes/          # Express routes
│   │   ├── models/          # Data models
│   │   ├── middleware/      # Auth & validation
│   │   └── config/          # Configuration
│   ├── prisma/              # Database schema & migrations
│   └── package.json         # Node.js dependencies
├── nextjs-frontend/         # Next.js frontend with React SSR
│   ├── src/
│   │   ├── app/            # Next.js 13+ app directory
│   │   ├── components/     # React components
│   │   ├── lib/           # Utilities & API calls
│   │   └── styles/        # Tailwind CSS
│   └── package.json       # Frontend dependencies
├── python-agent/           # AI agent for product sourcing
│   ├── main.py            # Main agent script
│   ├── requirements.txt   # Python dependencies
│   └── logs/              # Agent logs
├── monitoring/             # Grafana and Prometheus
├── docker-compose.yml      # M4 Mac optimized containers
└── Makefile               # Management commands
```

## 🎉 Success Indicators

When everything is working correctly, you'll see:
- ✅ Beautiful e-commerce store at http://localhost:3000
- ✅ API responding at http://localhost:3001
- ✅ Products being imported by AI agent every 15 minutes
- ✅ PostgreSQL database with product data
- ✅ Grafana dashboards showing metrics
- ✅ Health checks passing for all services

## 📞 Development Workflow

1. **Start Development**: `make dev`
2. **Watch Logs**: `make logs`
3. **Add Products**: AI agent runs automatically
4. **Test API**: Visit http://localhost:3001/health
5. **View Store**: Visit http://localhost:3000
6. **Monitor**: Visit http://localhost:3002 (Grafana)

## 🏆 Key Improvements Over .NET Version

This Node.js version resolves common issues:
- ✅ Better ARM64/M4 Mac compatibility
- ✅ Faster startup times with Node.js
- ✅ Modern React with Server-Side Rendering
- ✅ Type-safe development with TypeScript
- ✅ Simplified database operations with Prisma
- ✅ Better developer experience
- ✅ Reduced memory usage
- ✅ Faster build times

## 🔧 API Endpoints

### Products
- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get single product
- `POST /api/products/bulk-import` - Bulk import products (AI agent)

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Orders (Protected)
- `GET /api/orders` - Get user orders
- `POST /api/orders` - Create new order

### System
- `GET /health` - Health check
- `GET /` - API status

---

**Built with ❤️ for Canadian entrepreneurs** 🇨🇦

Ready to revolutionize your e-commerce business with AI and modern Node.js? Start with `make quick-start` and watch your automated store come to life!
