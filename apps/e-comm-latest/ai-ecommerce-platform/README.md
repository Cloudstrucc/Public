# 🤖 AI-Powered E-commerce Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![.NET](https://img.shields.io/badge/.NET-8.0-purple)](https://dotnet.microsoft.com/)
[![Python](https://img.shields.io/badge/Python-3.11-blue)](https://python.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue)](https://docker.com/)
[![Blazor](https://img.shields.io/badge/Blazor-Server-purple)](https://blazor.net/)

A complete AI-powered dropshipping e-commerce platform that automates product sourcing, market research, and order fulfillment from Asian commerce sites to Canadian consumers.

## 🌟 Key Features

### 🤖 **AI-Powered Automation**
- **Real Web Scraping**: Advanced scraping with anti-detection for Temu, SHEIN, AliExpress
- **Market Research**: Canadian market analysis using Google Trends, Amazon data, social sentiment
- **Intelligent Pricing**: Dynamic 20% markup with market-based adjustments
- **Order Automation**: Automatic supplier order placement and tracking

### 💳 **Payment & Commerce**
- **Stripe Integration**: Complete payment processing with CAD support
- **Multi-step Checkout**: Seamless customer experience with address management
- **Order Tracking**: Real-time status updates and shipping notifications
- **Customer Accounts**: Saved addresses, order history, and preferences

### 🏢 **Enterprise CRM Integration**
- **Microsoft Power Apps**: Complete CRM with custom entities and workflows
- **Customer Analytics**: Behavior tracking and segmentation
- **Inventory Management**: Stock level monitoring and alerts
- **Business Intelligence**: Dashboards and reporting

### 🛡️ **Security & Monitoring**
- **Enterprise Security**: JWT authentication, rate limiting, CORS protection
- **Comprehensive Monitoring**: Prometheus, Grafana, ELK stack
- **Automated Backups**: Database and configuration backup
- **Health Checks**: Service monitoring and alerting

## 🚀 Quick Start

### Prerequisites
- **Docker Desktop 4.0+** with at least 8GB RAM allocated
- **20GB+ free disk space** for containers and data
- **Valid Stripe account** (free test account works)
- **Microsoft Power Platform environment** (optional but recommended)

### 1. Clone & Setup
```bash
git clone https://github.com/your-username/ai-ecommerce-platform.git
cd ai-ecommerce-platform

# Quick automated setup
make quick-start

# Or manual setup
make setup
```

### 2. Configure Environment (IMPORTANT!)
```bash
# Copy the example environment file
cp .env.example .env

# Edit with your actual configuration
nano .env  # or use your preferred editor
```

### 3. Deploy
```bash
# Development mode (recommended for first time)
make dev

# Production mode (for live deployment)
make prod
```

### 4. Access Your Platform
- **🛍️ E-commerce Frontend**: http://localhost:5000
- **🔧 API Documentation**: http://localhost:7001/swagger
- **📊 Monitoring Dashboard**: http://localhost:3000 (admin/admin123)
- **🔍 Log Analysis**: http://localhost:5601

## 🔧 **Detailed Configuration Guide**

### 🗄️ **Database Configuration**

#### **SQL Server Setup (Automatic)**
The platform uses **Microsoft SQL Server 2022** running in a Docker container - **no separate installation needed!**

```bash
# Default configuration (works out of the box)
DB_CONNECTION_STRING=Server=sqlserver;Database=EcommerceAI;User=sa;Password=YourStrong@Passw0rd123!;TrustServerCertificate=true;MultipleActiveResultSets=true
```

**Connection String Breakdown:**
- `Server=sqlserver` → Docker container name (not external server)
- `Database=EcommerceAI` → Database name (auto-created)
- `User=sa` → SQL Server admin user
- `Password=YourStrong@Passw0rd123!` → Admin password
- `TrustServerCertificate=true` → Skip SSL validation (development)
- `MultipleActiveResultSets=true` → Allow multiple queries

#### **SQL Server Container Details:**
```yaml
# From docker-compose.yml
sqlserver:
  image: mcr.microsoft.com/mssql/server:2022-latest  # Microsoft SQL Server 2022
  container_name: ecommerce-sqlserver
  environment:
    - SA_PASSWORD=YourStrong@Passw0rd123!
    - MSSQL_PID=Developer                            # Free Developer Edition
  ports:
    - "1433:1433"                                    # Standard SQL Server port
```

#### **Alternative Database Configurations:**

**For External SQL Server:**
```bash
# Azure SQL Database
DB_CONNECTION_STRING=Server=your-server.database.windows.net;Database=EcommerceAI;User=your-user;Password=your-password;Encrypt=true

# Local SQL Server instance
DB_CONNECTION_STRING=Server=localhost;Database=EcommerceAI;Integrated Security=true

# SQL Server Express
DB_CONNECTION_STRING=Server=.\SQLEXPRESS;Database=EcommerceAI;Integrated Security=true
```

### 💳 **Environment Configuration (.env File)**

#### **REQUIRED Configuration (Must Configure These)**

##### **1. Stripe Payment Processing**
```bash
# Get these from https://stripe.com dashboard
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
```

**How to get Stripe keys:**
1. **Create account** at https://stripe.com
2. **Go to Dashboard** → Developers → API Keys
3. **Copy test keys** for development
4. **Set up webhook** at https://dashboard.stripe.com/webhooks
   - **Endpoint URL**: `https://yourdomain.com/api/webhooks/stripe`
   - **Events**: `payment_intent.succeeded`, `payment_intent.payment_failed`

##### **2. Security Configuration**
```bash
# Auto-generated secure key (don't change unless needed)
JWT_SECRET_KEY=your-super-secret-jwt-key-that-is-at-least-256-bits-long-for-security
```

#### **OPTIONAL Configuration (Enhances Features)**

##### **3. Microsoft Power Apps CRM Integration**
```bash
# Enable advanced CRM features
POWER_APPS_URL=https://your-environment.crm3.dynamics.com
POWER_APPS_CLIENT_ID=your-azure-ad-client-id-here
POWER_APPS_CLIENT_SECRET=your-azure-ad-client-secret-here
POWER_APPS_TENANT_ID=your-azure-tenant-id-here
```

**How to set up Power Apps:**
1. **Go to** https://make.powerapps.com
2. **Create new environment** or use existing
3. **Register app** in Azure Active Directory:
   - Go to https://portal.azure.com
   - Navigate to "Azure Active Directory" → "App registrations"
   - Click "New registration"
   - Set redirect URI and get Client ID/Secret
4. **Grant permissions** to Dynamics 365/Power Platform

##### **4. Market Research APIs (OPTIONAL - Enhances Market Analysis)**
```bash
# Amazon Product Advertising API (for competitive analysis)
AMAZON_API_KEY=your-amazon-product-api-key-here
AMAZON_ASSOCIATE_TAG=your-amazon-associate-tag

# Google APIs (for trends and search data)
GOOGLE_API_KEY=your-google-api-key-here
GOOGLE_SEARCH_ENGINE_ID=your-custom-search-engine-id

# Social media sentiment analysis
TWITTER_BEARER_TOKEN=your-twitter-api-bearer-token
REDDIT_CLIENT_ID=your-reddit-api-client-id
REDDIT_CLIENT_SECRET=your-reddit-api-client-secret
```

**📋 Detailed Setup Instructions for Market Research APIs:**

**🛒 Amazon Product Advertising API Setup:**
1. **Join Amazon Associates Program**:
   - Go to https://affiliate-program.amazon.ca (for Canada)
   - Click "Join Now for Free"
   - Complete application with your website/app details
   - Wait for approval (usually 1-3 days)

2. **Get Product Advertising API Access**:
   - After Associates approval, go to https://webservices.amazon.com/paapi5/
   - Sign in with your Amazon Associates account
   - Click "Request Access" for Product Advertising API
   - Fill out the application form
   - Wait for API access approval (can take 1-2 weeks)

3. **Obtain API Credentials**:
   - Once approved, go to https://webservices.amazon.com/paapi5/scratchpad
   - Navigate to "Manage Your Account" → "Security Credentials"
   - Create new Access Key ID and Secret Access Key
   - Note your Associate Tag from Associates Central

4. **Configure in .env**:
   ```bash
   AMAZON_API_KEY=AKIA1234567890EXAMPLE
   AMAZON_ASSOCIATE_TAG=yourtag-20
   AMAZON_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
   ```

**🔍 Google APIs Setup:**
1. **Create Google Cloud Project**:
   - Go to https://console.cloud.google.com/
   - Click "New Project" or select existing project
   - Name your project (e.g., "EcommerceAI-Research")

2. **Enable Required APIs**:
   - In the Cloud Console, go to "APIs & Services" → "Library"
   - Search and enable these APIs:
     - **Custom Search JSON API** (for search data)
     - **YouTube Data API v3** (for video trends)
     - **Google Trends API** (if available)

3. **Create API Credentials**:
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "API Key"
   - Copy the generated API key
   - **Restrict the API key** for security:
     - Click on the API key to edit
     - Under "API restrictions," select "Restrict key"
     - Choose the APIs you enabled above

4. **Set Up Custom Search Engine**:
   - Go to https://cse.google.com/
   - Click "Add" to create new search engine
   - In "Sites to search," enter: `amazon.ca`, `walmart.ca`, `canadiantire.ca`
   - Click "Create"
   - Get your Search Engine ID from the "Setup" tab

5. **Configure in .env**:
   ```bash
   GOOGLE_API_KEY=AIzaSyDOCAbC123DEF456GHI789JKL-MNO012
   GOOGLE_SEARCH_ENGINE_ID=012345678901234567890:abcdefghijk
   ```

**🐦 Twitter API Setup:**
1. **Apply for Twitter Developer Account**:
   - Go to https://developer.twitter.com/
   - Click "Apply for a developer account"
   - Choose "Hobbyist" → "Exploring the API"
   - Fill out application form explaining your use case
   - Wait for approval (usually 1-2 days)

2. **Create Twitter App**:
   - Once approved, go to https://developer.twitter.com/en/portal/dashboard
   - Click "Create App"
   - Fill in app details:
     - **App name**: "EcommerceAI Market Research"
     - **Description**: "Market sentiment analysis for Canadian e-commerce"
   - Click "Complete"

3. **Generate Bearer Token**:
   - In your app dashboard, go to "Keys and tokens"
   - Under "Bearer Token," click "Generate"
   - Copy the bearer token immediately (you won't see it again)

4. **Configure in .env**:
   ```bash
   TWITTER_BEARER_TOKEN=AAAAAAAAAAAAAAAAAAAAAG%2FHBwEAAAAAa4hmn%2FA
   ```

**🔴 Reddit API Setup:**
1. **Create Reddit Account**:
   - Go to https://www.reddit.com/ and create account if needed
   - Verify your email address

2. **Create Reddit App**:
   - Go to https://www.reddit.com/prefs/apps
   - Scroll down and click "Create App" or "Create Another App"
   - Fill in details:
     - **Name**: "EcommerceAI Market Research"
     - **App type**: Select "script"
     - **Description**: "Market analysis for Canadian e-commerce trends"
     - **About URL**: Your website or GitHub repo
     - **Redirect URI**: `http://localhost:8080` (for development)
   - Click "Create app"

3. **Get API Credentials**:
   - After creating, you'll see your app listed
   - **Client ID**: The string under your app name (starts with random letters)
   - **Client Secret**: Click "edit" to see the secret

4. **Configure in .env**:
   ```bash
   REDDIT_CLIENT_ID=dJ2miIQRTbgdNQ
   REDDIT_CLIENT_SECRET=xvFZINNh-1234567890abcdef
   REDDIT_USER_AGENT=EcommerceAI:v1.0 (by /u/yourusername)
   ```

##### **5. Web Scraping Enhancement (OPTIONAL - Improves Reliability & Speed)**
```bash
# Proxy rotation services (bypass geo-restrictions and rate limits)
PROXY_SERVICE_API_KEY=your-proxy-rotation-service-api-key
PROXY_SERVICE_URL=http://your-proxy-service.com
PROXY_USERNAME=your-proxy-username
PROXY_PASSWORD=your-proxy-password

# CAPTCHA solving services (automated CAPTCHA handling)
CAPTCHA_SOLVER_API_KEY=your-2captcha-or-anticaptcha-api-key
CAPTCHA_SOLVER_SERVICE=2captcha

# Browser automation enhancement
BROWSERLESS_API_KEY=your-browserless-io-api-key
SCRAPING_API_KEY=your-scraping-api-service-key
```

**📋 Detailed Setup Instructions for Web Scraping Enhancement:**

**🌐 Proxy Services Setup:**

**Option A: ProxyMesh (Recommended)**
1. **Sign up for ProxyMesh**:
   - Go to https://proxymesh.com/
   - Click "Sign Up" and choose a plan:
     - **Starter Plan**: $10/month, 10 IPs, 100GB bandwidth
     - **Production Plan**: $30/month, 100 IPs, 500GB bandwidth
   - Complete registration and payment

2. **Get Proxy Credentials**:
   - Login to ProxyMesh dashboard
   - Go to "Proxy List" to see your available proxies
   - Note the proxy endpoints (e.g., `us-wa.proxymesh.com:31280`)
   - Your username and password are shown in the dashboard

3. **Configure in .env**:
   ```bash
   PROXY_SERVICE_URL=http://us-wa.proxymesh.com:31280
   PROXY_USERNAME=your-proxymesh-username
   PROXY_PASSWORD=your-proxymesh-password
   PROXY_SERVICE_API_KEY=not-needed-for-proxymesh
   ```

**Option B: Bright Data (High Volume)**
1. **Sign up for Bright Data**:
   - Go to https://brightdata.com/
   - Click "Get Started" and choose "Residential Proxies"
   - Plans start at $500/month for serious commercial use
   - Complete enterprise onboarding process

2. **Create Proxy Zone**:
   - In dashboard, go to "Proxy" → "Zone"
   - Click "Create Zone"
   - Choose "Residential" proxy type
   - Configure zone settings

3. **Get API Credentials**:
   - In your zone, find the endpoint URL
   - Generate API key from "API" section
   - Note your zone credentials

4. **Configure in .env**:
   ```bash
   PROXY_SERVICE_URL=http://zproxy.lum-superproxy.io:22225
   PROXY_USERNAME=brd-customer-hl_12345678-zone-residential
   PROXY_PASSWORD=your-bright-data-password
   PROXY_SERVICE_API_KEY=your-bright-data-api-key
   ```

**Option C: SmartProxy (Budget-Friendly)**
1. **Sign up for SmartProxy**:
   - Go to https://smartproxy.com/
   - Choose "Residential Proxies" plan
   - Plans start at $12.5/month for 2GB
   - Complete registration

2. **Configure Proxy**:
   - Login to SmartProxy dashboard
   - Go to "Proxy Setup"
   - Choose "Endpoint Generator"
   - Generate endpoints for your location

3. **Configure in .env**:
   ```bash
   PROXY_SERVICE_URL=http://gate.smartproxy.com:10001
   PROXY_USERNAME=your-smartproxy-username
   PROXY_PASSWORD=your-smartproxy-password
   ```

**🤖 CAPTCHA Solving Services Setup:**

**Option A: 2captcha (Most Popular)**
1. **Create 2captcha Account**:
   - Go to https://2captcha.com/
   - Click "Sign Up" (it's free to start)
   - Verify your email address
   - Login to your dashboard

2. **Add Funds**:
   - Go to "Add Funds" in dashboard
   - Minimum deposit is usually $1-3
   - **Pricing**: ~$1-2 per 1000 CAPTCHAs solved
   - Payment methods: PayPal, crypto, bank transfer

3. **Get API Key**:
   - In dashboard, go to "Settings"
   - Copy your API key (32-character string)

4. **Configure in .env**:
   ```bash
   CAPTCHA_SOLVER_API_KEY=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
   CAPTCHA_SOLVER_SERVICE=2captcha
   ```

**Option B: Anti-Captcha**
1. **Create Anti-Captcha Account**:
   - Go to https://anti-captcha.com/
   - Register for free account
   - Verify email and login

2. **Fund Account**:
   - Go to "Add Funds"
   - Minimum deposit: $5
   - **Pricing**: Similar to 2captcha, ~$1-2 per 1000 solves

3. **Get API Key**:
   - In dashboard, find your API key
   - Copy the key string

4. **Configure in .env**:
   ```bash
   CAPTCHA_SOLVER_API_KEY=your-anti-captcha-api-key
   CAPTCHA_SOLVER_SERVICE=anticaptcha
   ```

**🚀 Browser Automation Enhancement:**

**Option A: Browserless.io (Cloud Browsers)**
1. **Sign up for Browserless**:
   - Go to https://www.browserless.io/
   - Choose a plan:
     - **Startup**: $29/month, 5 concurrent browsers
     - **Business**: $79/month, 10 concurrent browsers
   - Complete registration

2. **Get API Token**:
   - Login to dashboard
   - Go to "Account" → "API Tokens"
   - Generate new token

3. **Configure in .env**:
   ```bash
   BROWSERLESS_API_KEY=your-browserless-api-token
   BROWSERLESS_ENDPOINT=https://chrome.browserless.io/
   ```

**Option B: ScrapingBee (All-in-One)**
1. **Sign up for ScrapingBee**:
   - Go to https://www.scrapingbee.com/
   - Choose plan:
     - **Freelancer**: $49/month, 150k API calls
     - **Startup**: $99/month, 350k API calls
   - Complete registration

2. **Get API Key**:
   - In dashboard, find your API key
   - Copy the key for configuration

3. **Configure in .env**:
   ```bash
   SCRAPING_API_KEY=your-scrapingbee-api-key
   SCRAPING_API_ENDPOINT=https://app.scrapingbee.com/api/v1/
   ```

**⚙️ Configuration Examples for Different Setups:**

**Basic Setup (Free/Low Cost)**:
```bash
# Use only free/cheap services
GOOGLE_API_KEY=your-google-api-key
REDDIT_CLIENT_ID=your-reddit-client-id
REDDIT_CLIENT_SECRET=your-reddit-secret
# Skip paid proxy/captcha services
```

**Professional Setup (Recommended)**:
```bash
# Market research APIs
AMAZON_API_KEY=your-amazon-api-key
GOOGLE_API_KEY=your-google-api-key
TWITTER_BEARER_TOKEN=your-twitter-token
REDDIT_CLIENT_ID=your-reddit-client-id

# Basic proxy service
PROXY_SERVICE_URL=http://us-wa.proxymesh.com:31280
PROXY_USERNAME=your-proxymesh-username
PROXY_PASSWORD=your-proxymesh-password

# CAPTCHA solving
CAPTCHA_SOLVER_API_KEY=your-2captcha-key
CAPTCHA_SOLVER_SERVICE=2captcha
```

**Enterprise Setup (Maximum Performance)**:
```bash
# All market research APIs
AMAZON_API_KEY=your-amazon-api-key
AMAZON_ASSOCIATE_TAG=your-associate-tag
GOOGLE_API_KEY=your-google-api-key
GOOGLE_SEARCH_ENGINE_ID=your-search-engine-id
TWITTER_BEARER_TOKEN=your-twitter-token
REDDIT_CLIENT_ID=your-reddit-client-id
REDDIT_CLIENT_SECRET=your-reddit-secret

# High-performance proxy service
PROXY_SERVICE_URL=http://zproxy.lum-superproxy.io:22225
PROXY_USERNAME=brd-customer-your-zone
PROXY_PASSWORD=your-bright-data-password
PROXY_SERVICE_API_KEY=your-bright-data-api-key

# Premium CAPTCHA solving
CAPTCHA_SOLVER_API_KEY=your-2captcha-key
CAPTCHA_SOLVER_SERVICE=2captcha

# Cloud browser automation
BROWSERLESS_API_KEY=your-browserless-token
SCRAPING_API_KEY=your-scrapingbee-key
```

**💰 Cost Breakdown for Optional Services:**

| Service Category | Free Option | Budget Option | Professional Option |
|------------------|-------------|---------------|-------------------|
| **Market Research** | Google Trends API Free | Google APIs + Reddit ($0-10/month) | All APIs ($50-100/month) |
| **Proxy Services** | None reliable | SmartProxy ($12.5/month) | ProxyMesh ($30/month) |
| **CAPTCHA Solving** | Manual only | 2captcha ($10-20/month) | Anti-Captcha ($50+/month) |
| **Browser Automation** | Local browsers | Browserless Startup ($29/month) | Enterprise ($100+/month) |
| **Total Monthly Cost** | **$0** | **$50-70** | **$200-300** |

**🎯 Recommended Starting Configuration:**
For most users, start with this configuration and add services as needed:
```bash
# Essential (free)
GOOGLE_API_KEY=your-google-api-key
REDDIT_CLIENT_ID=your-reddit-client-id
REDDIT_CLIENT_SECRET=your-reddit-secret

# Add when ready for serious scraping
PROXY_SERVICE_URL=http://us-wa.proxymesh.com:31280
PROXY_USERNAME=your-proxymesh-username
PROXY_PASSWORD=your-proxymesh-password
CAPTCHA_SOLVER_API_KEY=your-2captcha-key
```

##### **6. Email & Notifications**
```bash
# Order confirmation emails
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-email-app-password
SMTP_FROM_ADDRESS=noreply@yourdomain.com

# Slack alerts for system monitoring
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/your/slack/webhook
```

#### **Business Configuration**
```bash
# Pricing and business rules
DEFAULT_MARKUP_PERCENTAGE=20
MINIMUM_MARKUP_PERCENTAGE=15
MAXIMUM_MARKUP_PERCENTAGE=50

# Shipping settings (CAD)
FREE_SHIPPING_THRESHOLD=50.00
DEFAULT_SHIPPING_COST=9.99
EXPRESS_SHIPPING_COST=19.99

# Canadian tax rates
HST_RATE=0.13  # Ontario, New Brunswick, Newfoundland
GST_RATE=0.05  # Federal GST
PST_RATE=0.07  # Provincial (varies by province)

# Currency
DEFAULT_CURRENCY=CAD
SUPPORTED_CURRENCIES=CAD,USD
```

#### **Feature Toggles**
```bash
# Enable/disable major features
ENABLE_REAL_SCRAPING=true
ENABLE_ANTI_DETECTION=true
ENABLE_CAPTCHA_SOLVING=false
ENABLE_MARKET_RESEARCH=true
ENABLE_POWER_APPS=false
ENABLE_EMAIL_NOTIFICATIONS=false
```

### 🔌 **Service Configuration**

#### **Redis Cache**
```bash
# Automatic configuration (no changes needed)
REDIS_CONNECTION_STRING=redis:6379,password=RedisPass123!
```

#### **Monitoring & Analytics**
```bash
# Grafana admin access
GRAFANA_ADMIN_PASSWORD=admin123

# Data retention
PROMETHEUS_RETENTION_TIME=15d
```

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx Proxy   │    │  Blazor Frontend│    │   .NET Core API │
│   Port 80/443   │◄──►│   Port 5000     │◄──►│   Port 7001     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                │              ┌─────────────────┐
                                │              │   SQL Server    │
                                │              │   Port 1433     │
                                │              │   (Container)   │
                                │              └─────────────────┘
                                │                       │
┌─────────────────┐            │              ┌─────────────────┐
│  Python AI      │            │              │     Redis       │
│  Agent Service  │◄───────────┼──────────────┤   Port 6379     │
│  (Scraping &    │            │              │   (Container)   │
│   Research)     │            │              └─────────────────┘
└─────────────────┘            │
         │                     │
         │              ┌─────────────────┐
         └──────────────►│  Power Apps CRM │
                        │  (External)     │
                        └─────────────────┘
```

## 📊 Technology Stack Details

### **Backend (.NET Core 8)**
- **Framework**: ASP.NET Core Web API with Entity Framework Core
- **Database**: Microsoft SQL Server 2022 (containerized)
- **Authentication**: JWT Bearer tokens with secure key generation
- **Payment**: Stripe.NET SDK with webhook support
- **Caching**: Redis with distributed caching
- **Monitoring**: Prometheus metrics and health checks

### **Frontend (Blazor Server)**
- **Framework**: Blazor Server with SignalR for real-time updates
- **UI Library**: MudBlazor components for modern, responsive design
- **State Management**: Scoped services with Blazored.LocalStorage
- **Payment UI**: Stripe Elements integration with PCI compliance
- **Authentication**: Cookie-based with JWT integration

### **AI & Automation (Python 3.11)**
- **Web Scraping**: Playwright + Selenium with anti-detection
- **Market Research**: PyTrends (Google Trends) + social media APIs
- **Data Processing**: Pandas, NumPy, scikit-learn
- **Image Processing**: PIL, OpenCV for product image analysis
- **NLP**: NLTK, TextBlob for sentiment analysis

### **Infrastructure & DevOps**
- **Containerization**: Docker Compose with health checks
- **Reverse Proxy**: Nginx with SSL termination and load balancing
- **Monitoring**: Prometheus + Grafana dashboards
- **Logging**: Centralized logging with structured logs
- **Database**: Automated backups and recovery

## 🚀 Deployment Options

### **Development Environment**
```bash
# Start everything for development
make dev

# View logs
make logs

# Check service status
make status
```

### **Production Environment**
```bash
# Deploy to production
make prod

# Perform health checks
make health-check

# Backup database
make backup
```

### **Cloud Deployment Ready**
- **Azure**: ARM templates and container instances
- **AWS**: ECS/EKS deployment configurations
- **Google Cloud**: GKE manifests and cloud SQL
- **Docker Swarm**: Multi-node cluster setup

## 🔍 **Troubleshooting Guide**

### **Common Issues & Solutions**

#### **1. SQL Server Connection Failed**
```bash
# Check if SQL Server container is running
docker ps | grep sqlserver

# View SQL Server logs
docker logs ecommerce-sqlserver

# Restart SQL Server
docker-compose restart sqlserver

# Connect to SQL Server directly
make db-shell
```

#### **2. Stripe Payment Issues**
- ✅ **Verify API keys** are correct in `.env`
- ✅ **Check webhook endpoint** is accessible
- ✅ **Use test keys** for development
- ✅ **Review Stripe dashboard** for webhook delivery logs

#### **3. Python Agent Not Working**
```bash
# Check agent logs
make logs-agent

# Verify API connectivity
docker exec ecommerce-python-agent curl http://dotnet-api:80/health

# Restart agent
docker-compose restart python-agent
```

#### **4. Frontend Not Loading**
```bash
# Check frontend logs
make logs-frontend

# Verify API connection
curl http://localhost:7001/health

# Check if ports are available
netstat -an | grep ":5000\|:7001"
```

#### **5. Power Apps Integration Issues**
- ✅ **Verify Azure AD app permissions**
- ✅ **Check client secret expiration**
- ✅ **Test API connectivity** with Power Platform
- ✅ **Review authentication logs**

### **Health Check Commands**
```bash
# Overall system health
make health-check

# Individual service health
curl http://localhost:5000/health    # Frontend
curl http://localhost:7001/health    # API
curl http://localhost:9200/_cluster/health  # Elasticsearch
```

### **Performance Optimization**

#### **Database Performance**
```bash
# Monitor database performance
docker exec ecommerce-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "YourStrong@Passw0rd123!" \
  -Q "SELECT * FROM sys.dm_exec_requests"

# Check index usage
make db-shell
# Run performance queries in SQL Management Studio
```

#### **Memory & CPU Monitoring**
```bash
# View resource usage
docker stats

# Monitor specific container
docker stats ecommerce-python-agent

# Check system resources
htop  # or Activity Monitor on Mac
```

## 📈 Monitoring & Analytics

### **Business Metrics Dashboard**
Access Grafana at http://localhost:3000 (admin/admin123) to view:
- **Sales Metrics**: Conversion rates, revenue, order values
- **Product Performance**: Top-selling items, demand scores
- **Customer Analytics**: Acquisition, retention, lifetime value
- **Market Insights**: Trend analysis, competitive positioning

### **Technical Monitoring**
- **API Performance**: Response times, error rates, throughput
- **Scraping Success**: Product import rates, site availability
- **System Health**: CPU, memory, disk usage, uptime
- **Security Events**: Failed logins, rate limit violations

### **Log Analysis**
Access Kibana at http://localhost:5601 for:
- **Centralized Logging**: All application logs in one place
- **Error Tracking**: Real-time error monitoring and alerts
- **Performance Analysis**: Slow query detection
- **Security Monitoring**: Suspicious activity detection

## 🔒 Security Features

### **API Security**
- **JWT Authentication**: Secure token-based authentication
- **Rate Limiting**: 60 requests/minute per IP for APIs
- **CORS Protection**: Configured allowed origins
- **Input Validation**: All inputs sanitized and validated

### **Data Protection**
- **Encryption**: All sensitive data encrypted at rest and in transit
- **PCI Compliance**: Payment data handled securely via Stripe
- **PIPEDA Compliance**: Canadian privacy law adherence
- **SQL Injection Prevention**: Parameterized queries via Entity Framework

### **Infrastructure Security**
- **Container Isolation**: Services run in isolated Docker containers
- **Network Segmentation**: Internal Docker network for service communication
- **Secret Management**: Environment variables for sensitive configuration
- **Regular Updates**: Automated security patches for base images

## 📚 Additional Documentation

### **API Documentation**
- **Interactive Docs**: http://localhost:7001/swagger
- **OpenAPI Spec**: Complete API specification with examples
- **Authentication Guide**: How to obtain and use JWT tokens
- **Webhook Documentation**: Stripe webhook implementation

### **Development Guides**
- **Getting Started**: Step-by-step development setup
- **Adding New Features**: Architecture patterns and best practices
- **Testing Guide**: Unit, integration, and end-to-end testing
- **Deployment Guide**: Production deployment checklist

### **Business Documentation**
- **User Manual**: How to use the e-commerce platform
- **Admin Guide**: Managing products, orders, and customers
- **Market Research**: Understanding the Canadian market analysis
- **Legal Compliance**: PIPEDA, consumer protection, tax obligations

## 🧪 Testing

### **Automated Testing**
```bash
# Run all tests
make test

# Unit tests only
make test-unit

# Integration tests
make test-integration

# End-to-end tests
make test-e2e
```

### **Manual Testing Checklist**
- ✅ **Product Scraping**: Verify products are imported correctly
- ✅ **Payment Flow**: Complete test purchase with Stripe test cards
- ✅ **Order Management**: Check order lifecycle from cart to delivery
- ✅ **Market Research**: Validate Canadian market data accuracy
- ✅ **CRM Integration**: Test Power Apps data synchronization

## 🤝 Contributing

### **Development Setup**
```bash
# Fork and clone repository
git clone https://github.com/your-username/ai-ecommerce-platform.git
cd ai-ecommerce-platform

# Install development dependencies
make install-dev

# Start development environment
make dev

# Run tests before committing
make test
```

### **Code Standards**
- **C#**: Follow Microsoft coding conventions with EditorConfig
- **Python**: PEP 8 style guide with Black formatter
- **TypeScript/JavaScript**: ESLint with Prettier
- **Documentation**: Comprehensive inline and API documentation

### **Pull Request Process**
1. **Fork** the repository
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Write tests** for new functionality
4. **Ensure all tests pass**: `make test`
5. **Update documentation** as needed
6. **Commit changes**: `git commit -m 'Add amazing feature'`
7. **Push to branch**: `git push origin feature/amazing-feature`
8. **Open Pull Request** with detailed description

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Community

### **Getting Help**
- **Documentation**: Comprehensive guides in `docs/` directory
- **Issues**: GitHub Issues for bug reports and feature requests
- **Discussions**: GitHub Discussions for questions and community support
- **Wiki**: Additional tutorials, examples, and troubleshooting

### **Community Resources**
- **Discord Server**: Real-time chat and support
- **Forum**: Discussions about e-commerce automation
- **Blog**: Tutorials and case studies
- **Newsletter**: Platform updates and e-commerce tips

## 🎯 Roadmap

### **Phase 1: Core Platform** ✅
- [x] Basic product scraping and import
- [x] Stripe payment processing with CAD support
- [x] Order management and customer accounts
- [x] Blazor frontend with modern UI

### **Phase 2: AI Enhancement** ✅
- [x] Advanced anti-detection web scraping
- [x] Canadian market research and analysis
- [x] Power Apps CRM integration
- [x] Automated order placement and tracking

### **Phase 3: Advanced Features** 🚧
- [ ] Machine learning product recommendations
- [ ] Advanced inventory management with forecasting
- [ ] Multi-vendor marketplace functionality
- [ ] Mobile app for iOS and Android

### **Phase 4: Enterprise Features** 📋
- [ ] Advanced analytics and business intelligence
- [ ] International market expansion
- [ ] B2B wholesale functionality
- [ ] Advanced fraud detection and prevention

### **Phase 5: AI Innovation** 🔮
- [ ] Computer vision for automatic product categorization
- [ ] Natural language generation for product descriptions
- [ ] Predictive pricing optimization
- [ ] Autonomous supplier relationship management

## 📞 Contact & Support

- **Project Repository**: https://github.com/your-username/ai-ecommerce-platform
- **Documentation**: https://docs.your-platform.com
- **Support Email**: support@your-platform.com
- **Discord Community**: https://discord.gg/your-platform

---

**Built with ❤️ for Canadian entrepreneurs and e-commerce innovators**

*This platform represents the future of AI-powered e-commerce, providing Canadian businesses with the tools they need to compete globally while focusing on their local market.*
