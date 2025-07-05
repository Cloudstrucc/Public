#!/bin/bash
# Complete AI-Powered E-commerce Platform Generator - Node.js Version
# Next.js Frontend + Express.js API + PostgreSQL + Python AI Agent
# Version 4.0.0 - Node.js Stack with SSR

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="ai-ecommerce-nodejs"
PROJECT_VERSION="4.0.0"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  COMPLETE AI E-COMMERCE PLATFORM (NODE.JS VERSION)              ║"
echo "║                                                                  ║"
echo "║  🐘 PostgreSQL Database (ARM64 Compatible)                      ║"
echo "║  ⚡ Next.js Frontend (React SSR)                                ║"
echo "║  🚀 Express.js API Backend                                       ║"
echo "║  🤖 AI Product Scraping & Market Research                       ║"
echo "║  💳 Complete Stripe Payment Integration                         ║"
echo "║  🔐 JWT Authentication & Session Management                     ║"
echo "║  📊 Canadian Market Analysis & Automation                       ║"
echo "║  🐳 Docker Compose (ARM64 + M4 Mac Compatible)                  ║"
echo "║  🎯 Modern Node.js Stack with TypeScript                        ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_section() {
    echo -e "${PURPLE}🔧 $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_section "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker Desktop first."
        print_info "Visit: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed."
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker Desktop."
        exit 1
    fi
    
    print_status "All prerequisites met"
}

# Check if directory exists
if [ -d "$PROJECT_NAME" ]; then
    print_warning "Directory $PROJECT_NAME already exists!"
    read -p "Remove it and create fresh? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_NAME"
        print_info "Removed existing directory"
    else
        print_error "Setup cancelled"
        exit 1
    fi
fi

check_prerequisites

print_section "Creating enhanced project structure..."

# Create main directory and navigate
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create all directories
mkdir -p python-agent/{agents,utils,logs,data,tests}
mkdir -p express-api/{src/{controllers,models,services,middleware,routes,utils,config},logs,tests,prisma}
mkdir -p nextjs-frontend/{src/{app,components,lib,hooks,types,styles},public,logs,tests}
mkdir -p nginx/{ssl,logs,conf.d}
mkdir -p monitoring/{grafana/{dashboards,datasources},prometheus,elasticsearch}
mkdir -p scripts/{deployment,maintenance,setup}
mkdir -p sql-scripts/{init,migrations,samples}
mkdir -p docs/{api,user,developer,architecture}
mkdir -p tests/{unit,integration,e2e,performance}
mkdir -p backups
mkdir -p ssl-certs

print_status "Directory structure created"

print_section "Creating configuration files..."

# Create .gitignore
cat > .gitignore << 'EOF'
# AI-Powered E-commerce Platform - Git Ignore (Node.js)

# Environment variables
.env
.env.local
.env.production
.env.development

# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Next.js
.next/
out/
.vercel/

# Production builds
dist/
build/

# Logs
logs/
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# IDE and editors
.vs/
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Docker
.docker/
docker-compose.override.yml

# Python
__pycache__/
*.py[cod]
*$py.class

# Database
*.db
*.sqlite
*.sqlite3

# TypeScript
*.tsbuildinfo

# Prisma
prisma/migrations/

# Test results
coverage/
*.coverage

# Temporary files
temp/
tmp/
*.tmp
*.temp

# Secrets and certificates
*.key
*.pem
*.crt
*.p12
*.pfx
EOF

print_status ".gitignore created"

# Create .env file
cat > .env << 'EOF'
# AI-Powered E-commerce Platform Environment Configuration
# Node.js Version with Next.js and Express.js

# Database Configuration
DATABASE_URL="postgresql://postgres:YourStrong@Passw0rd123!@postgres:5432/EcommerceAI?schema=public"
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=EcommerceAI
POSTGRES_USER=postgres
POSTGRES_PASSWORD=YourStrong@Passw0rd123!

# Redis Configuration  
REDIS_URL=redis://redis:6379
REDIS_PASSWORD=RedisPass123!

# Security
JWT_SECRET=nodejs-super-secret-jwt-key-that-is-exactly-256-bits-long-for-security-2024
SESSION_SECRET=session-secret-key-for-express-sessions
BCRYPT_ROUNDS=12

# API Configuration
API_PORT=3001
FRONTEND_PORT=3000
API_URL=http://express-api:3001
FRONTEND_URL=http://nextjs-frontend:3000

# Stripe (placeholder values - update with real keys if needed)
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Environment Settings
NODE_ENV=development
LOG_LEVEL=info
PYTHON_ENV=development
PYTHON_LOG_LEVEL=INFO

# Monitoring
GRAFANA_ADMIN_PASSWORD=admin123
PROMETHEUS_RETENTION_TIME=15d

# Feature flags
ENABLE_REAL_SCRAPING=true
ENABLE_MARKET_RESEARCH=true
EOF

print_status "Environment configuration created"

print_section "Creating Express.js API with PostgreSQL..."

# Create package.json for Express API
cat > express-api/package.json << 'EOF'
{
  "name": "ai-ecommerce-express-api",
  "version": "1.0.0",
  "description": "AI-Powered E-commerce API built with Express.js and PostgreSQL",
  "main": "dist/index.js",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "db:generate": "prisma generate",
    "db:push": "prisma db push",
    "db:migrate": "prisma migrate dev",
    "db:studio": "prisma studio",
    "db:seed": "tsx src/prisma/seed.ts"
  },
  "keywords": ["ecommerce", "ai", "express", "postgresql", "stripe"],
  "author": "AI E-commerce Platform",
  "license": "MIT",
  "dependencies": {
    "@prisma/client": "^5.7.1",
    "bcryptjs": "^2.4.3",
    "cors": "^2.8.5",
    "express": "^4.18.2",
    "express-rate-limit": "^7.1.5",
    "helmet": "^7.1.0",
    "jsonwebtoken": "^9.0.2",
    "redis": "^4.6.11",
    "stripe": "^14.9.0",
    "winston": "^3.11.0",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/bcryptjs": "^2.4.6",
    "@types/cors": "^2.8.17",
    "@types/express": "^4.17.21",
    "@types/jsonwebtoken": "^9.0.5",
    "@types/node": "^20.10.4",
    "jest": "^29.7.0",
    "prisma": "^5.7.1",
    "tsx": "^4.6.2",
    "typescript": "^5.3.3"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# Create TypeScript config for API
cat > express-api/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "removeComments": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noImplicitThis": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "moduleResolution": "node",
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    },
    "allowSyntheticDefaultImports": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "tests"
  ]
}
EOF

# Create Prisma schema with FIXED binary targets for ARM64 + OpenSSL 3.0
cat > express-api/prisma/schema.prisma << 'EOF'
// AI-Powered E-commerce Platform - Prisma Schema (ARM64 + OpenSSL 3.0 Compatible)
generator client {
  provider      = "prisma-client-js"
  binaryTargets = ["native", "linux-arm64-openssl-3.0.x"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  password  String
  firstName String?
  lastName  String?
  role      UserRole @default(USER)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // Relations
  orders Order[]

  @@map("users")
}

model Product {
  id               String   @id @default(cuid())
  sourceProductId  String
  sourceSite       String
  title            String
  description      String?
  sourcePrice      Decimal
  marketPrice      Decimal
  currency         String   @default("CAD")
  images           String[] @default([])
  category         String
  isActive         Boolean  @default(true)
  availability     Boolean  @default(true)
  supplierInfo     Json     @default("{}")
  specifications   Json     @default("{}")
  shippingInfo     Json     @default("{}")
  reviewsCount     Int      @default(0)
  rating           Decimal  @default(0)
  inventoryLevel   String   @default("In Stock")
  scrapedAt        DateTime @default(now())
  createdAt        DateTime @default(now())
  updatedAt        DateTime @updatedAt

  // Relations
  orderItems OrderItem[]

  @@unique([sourceProductId, sourceSite])
  @@map("products")
}

model Order {
  id              String      @id @default(cuid())
  userId          String
  customerEmail   String
  customerName    String?
  totalAmount     Decimal
  currency        String      @default("CAD")
  status          OrderStatus @default(PENDING)
  paymentIntentId String?
  shippingAddress Json        @default("{}")
  billingAddress  Json        @default("{}")
  createdAt       DateTime    @default(now())
  updatedAt       DateTime    @updatedAt

  // Relations
  user       User        @relation(fields: [userId], references: [id])
  orderItems OrderItem[]

  @@map("orders")
}

model OrderItem {
  id         String  @id @default(cuid())
  orderId    String
  productId  String
  quantity   Int
  unitPrice  Decimal
  totalPrice Decimal

  // Relations
  order   Order   @relation(fields: [orderId], references: [id])
  product Product @relation(fields: [productId], references: [id])

  @@map("order_items")
}

enum UserRole {
  USER
  ADMIN
}

enum OrderStatus {
  PENDING
  PAID
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
  REFUNDED
}
EOF

# Create Express.js server
cat > express-api/src/index.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { PrismaClient } from '@prisma/client';
import { createClient } from 'redis';

import logger from './config/logger';
import authRoutes from './routes/auth';
import productRoutes from './routes/products';
import orderRoutes from './routes/orders';
import { errorHandler } from './middleware/errorHandler';
import { authenticate } from './middleware/auth';

const app = express();
const port = process.env.API_PORT || 3001;

// Initialize Prisma
export const prisma = new PrismaClient();

// Initialize Redis
export const redis = createClient({
  url: process.env.REDIS_URL,
  password: process.env.REDIS_PASSWORD,
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true,
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});
app.use(limiter);

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    database: 'connected'
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', authenticate, orderRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: '🤖 AI-Powered E-commerce API (Node.js + PostgreSQL)',
    version: '1.0.0',
    documentation: '/api/docs',
    health: '/health'
  });
});

// Error handling
app.use(errorHandler);

// Start server
async function startServer() {
  try {
    // Connect to Redis
    await redis.connect();
    logger.info('✅ Connected to Redis');

    // Test database connection
    await prisma.$connect();
    logger.info('✅ Connected to PostgreSQL');

    app.listen(port, () => {
      logger.info(`🚀 Express.js API server running on port ${port}`);
      logger.info(`📊 Health check: http://localhost:${port}/health`);
    });
  } catch (error) {
    logger.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  logger.info('🛑 Shutting down gracefully...');
  await prisma.$disconnect();
  await redis.disconnect();
  process.exit(0);
});

startServer();
EOF

# Create logger configuration
cat > express-api/src/config/logger.ts << 'EOF'
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'ai-ecommerce-api' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
  ],
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

export default logger;
EOF

# Create authentication middleware
cat > express-api/src/middleware/auth.ts << 'EOF'
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { prisma } from '../index';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
    role: string;
  };
}

export const authenticate = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ error: 'Access denied. No token provided.' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: { id: true, email: true, role: true }
    });

    if (!user) {
      return res.status(401).json({ error: 'Invalid token.' });
    }

    req.user = user;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token.' });
  }
};

export const requireAdmin = (req: AuthRequest, res: Response, next: NextFunction) => {
  if (req.user?.role !== 'ADMIN') {
    return res.status(403).json({ error: 'Access denied. Admin required.' });
  }
  next();
};
EOF

# Create error handler middleware
cat > express-api/src/middleware/errorHandler.ts << 'EOF'
import { Request, Response, NextFunction } from 'express';
import logger from '../config/logger';

export const errorHandler = (
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  logger.error({
    message: error.message,
    stack: error.stack,
    url: req.url,
    method: req.method,
  });

  if (res.headersSent) {
    return next(error);
  }

  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong',
  });
};
EOF

# Create product routes
cat > express-api/src/routes/products.ts << 'EOF'
import express from 'express';
import { z } from 'zod';
import { prisma } from '../index';
import logger from '../config/logger';

const router = express.Router();

// Validation schemas
const ProductImportSchema = z.object({
  sourceProductId: z.string(),
  sourceSite: z.string(),
  title: z.string(),
  description: z.string().optional(),
  sourcePrice: z.number(),
  currency: z.string().default('CAD'),
  images: z.array(z.string()).default([]),
  category: z.string(),
  availability: z.boolean().default(true),
  supplierInfo: z.record(z.any()).default({}),
  specifications: z.record(z.any()).default({}),
  shippingInfo: z.record(z.any()).default({}),
  reviewsCount: z.number().default(0),
  rating: z.number().default(0),
  inventoryLevel: z.string().default('In Stock'),
});

// GET /api/products - Get all active products
router.get('/', async (req, res) => {
  try {
    const products = await prisma.product.findMany({
      where: { isActive: true },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });

    res.json(products);
  } catch (error) {
    logger.error('Error fetching products:', error);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// GET /api/products/:id - Get single product
router.get('/:id', async (req, res) => {
  try {
    const product = await prisma.product.findUnique({
      where: { id: req.params.id },
    });

    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.json(product);
  } catch (error) {
    logger.error('Error fetching product:', error);
    res.status(500).json({ error: 'Failed to fetch product' });
  }
});

// POST /api/products/bulk-import - Bulk import products
router.post('/bulk-import', async (req, res) => {
  try {
    const productDtos = z.array(ProductImportSchema).parse(req.body);
    
    logger.info(`Bulk importing ${productDtos.length} products`);
    
    const results = {
      newProducts: 0,
      updatedProducts: 0,
      errors: 0,
    };

    for (const dto of productDtos) {
      try {
        const existingProduct = await prisma.product.findUnique({
          where: {
            sourceProductId_sourceSite: {
              sourceProductId: dto.sourceProductId,
              sourceSite: dto.sourceSite,
            },
          },
        });

        if (existingProduct) {
          await prisma.product.update({
            where: { id: existingProduct.id },
            data: {
              title: dto.title,
              description: dto.description,
              sourcePrice: dto.sourcePrice,
              marketPrice: dto.sourcePrice * 1.2, // 20% markup
              images: dto.images,
              category: dto.category,
              availability: dto.availability,
              supplierInfo: dto.supplierInfo,
              specifications: dto.specifications,
              shippingInfo: dto.shippingInfo,
              reviewsCount: dto.reviewsCount,
              rating: dto.rating,
              inventoryLevel: dto.inventoryLevel,
              updatedAt: new Date(),
            },
          });
          results.updatedProducts++;
        } else {
          await prisma.product.create({
            data: {
              sourceProductId: dto.sourceProductId,
              sourceSite: dto.sourceSite,
              title: dto.title,
              description: dto.description,
              sourcePrice: dto.sourcePrice,
              marketPrice: dto.sourcePrice * 1.2, // 20% markup
              currency: dto.currency,
              images: dto.images,
              category: dto.category,
              availability: dto.availability,
              supplierInfo: dto.supplierInfo,
              specifications: dto.specifications,
              shippingInfo: dto.shippingInfo,
              reviewsCount: dto.reviewsCount,
              rating: dto.rating,
              inventoryLevel: dto.inventoryLevel,
              isActive: true,
            },
          });
          results.newProducts++;
        }
      } catch (error) {
        logger.error(`Error processing product ${dto.sourceProductId}:`, error);
        results.errors++;
      }
    }

    logger.info(`Successfully imported ${results.newProducts} new products and updated ${results.updatedProducts} existing products`);

    res.json({
      message: 'Products imported successfully',
      results,
    });
  } catch (error) {
    logger.error('Error importing products:', error);
    res.status(500).json({ error: 'Error importing products' });
  }
});

export default router;
EOF

# Create auth routes
cat > express-api/src/routes/auth.ts << 'EOF'
import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { prisma } from '../index';
import logger from '../config/logger';

const router = express.Router();

// Validation schemas
const RegisterSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  firstName: z.string().optional(),
  lastName: z.string().optional(),
});

const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string(),
});

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { email, password, firstName, lastName } = RegisterSchema.parse(req.body);

    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, parseInt(process.env.BCRYPT_ROUNDS!) || 12);

    // Create user
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        firstName,
        lastName,
      },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        createdAt: true,
      },
    });

    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET!,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'User created successfully',
      user,
      token,
    });
  } catch (error) {
    logger.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = LoginSchema.parse(req.body);

    // Find user
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET!,
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
      },
      token,
    });
  } catch (error) {
    logger.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

export default router;
EOF

# Create order routes
cat > express-api/src/routes/orders.ts << 'EOF'
import express from 'express';
import { AuthRequest } from '../middleware/auth';
import { prisma } from '../index';
import logger from '../config/logger';

const router = express.Router();

// GET /api/orders - Get user's orders
router.get('/', async (req: AuthRequest, res) => {
  try {
    const orders = await prisma.order.findMany({
      where: { userId: req.user!.id },
      include: {
        orderItems: {
          include: {
            product: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json(orders);
  } catch (error) {
    logger.error('Error fetching orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

export default router;
EOF

# Create Express Dockerfile (simplified for development)
cat > express-api/Dockerfile << 'EOF'
FROM node:18-slim

WORKDIR /app

# Install system dependencies including OpenSSL for Prisma
RUN apt-get update && apt-get install -y \
    curl \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Generate Prisma client with correct binary targets
RUN npx prisma generate

# Create logs directory
RUN mkdir -p logs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s \
  CMD curl -f http://localhost:3001/health || exit 1

# Expose port
EXPOSE 3001

# Start server in development mode
CMD ["npm", "run", "dev"]
EOF

print_status "Express.js API created"

print_section "Creating Next.js Frontend with React SSR..."

# Create package.json for Next.js
cat > nextjs-frontend/package.json << 'EOF'
{
  "name": "ai-ecommerce-nextjs-frontend",
  "version": "1.0.0",
  "description": "AI-Powered E-commerce Frontend built with Next.js and React",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^14.0.4",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@stripe/stripe-js": "^2.2.2",
    "axios": "^1.6.2",
    "tailwindcss": "^3.3.6",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.32",
    "lucide-react": "^0.294.0",
    "clsx": "^2.0.0",
    "date-fns": "^2.30.0"
  },
  "devDependencies": {
    "@types/node": "^20.10.4",
    "@types/react": "^18.2.45",
    "@types/react-dom": "^18.2.18",
    "typescript": "^5.3.3",
    "eslint": "^8.56.0",
    "eslint-config-next": "^14.0.4"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# Create Next.js config
cat > nextjs-frontend/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    serverActions: true,
  },
  images: {
    domains: ['images.unsplash.com', 'via.placeholder.com'],
  },
  env: {
    API_URL: process.env.API_URL || 'http://localhost:3001',
    STRIPE_PUBLISHABLE_KEY: process.env.STRIPE_PUBLISHABLE_KEY,
  },
  // Development optimizations
  webpack: (config, { dev }) => {
    if (dev) {
      config.watchOptions = {
        poll: 1000,
        aggregateTimeout: 300,
      }
    }
    return config
  },
}

module.exports = nextConfig
EOF

# Create TypeScript config for Next.js
cat > nextjs-frontend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "es6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

# Create Tailwind config
cat > nextjs-frontend/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
        gray: {
          50: '#f9fafb',
          100: '#f3f4f6',
          200: '#e5e7eb',
          300: '#d1d5db',
          400: '#9ca3af',
          500: '#6b7280',
          600: '#4b5563',
          700: '#374151',
          800: '#1f2937',
          900: '#111827',
        },
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'pulse-slow': 'pulse 3s infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
}
EOF

# Create PostCSS config
cat > nextjs-frontend/postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# Create main layout
cat > nextjs-frontend/src/app/layout.tsx << 'EOF'
import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import Header from '@/components/Header'
import Footer from '@/components/Footer'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: '🤖 AI E-commerce Store - Powered by AI & PostgreSQL',
  description: 'AI-Powered E-commerce Platform with automated product sourcing',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <div className="min-h-screen flex flex-col">
          <Header />
          <main className="flex-1">
            {children}
          </main>
          <Footer />
        </div>
      </body>
    </html>
  )
}
EOF

# Create global CSS
cat > nextjs-frontend/src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html {
    scroll-behavior: smooth;
  }
  
  body {
    @apply text-gray-900 bg-white;
  }
}

@layer components {
  .btn-primary {
    @apply bg-primary-600 hover:bg-primary-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200;
  }
  
  .btn-secondary {
    @apply bg-gray-200 hover:bg-gray-300 text-gray-900 font-medium py-2 px-4 rounded-lg transition-colors duration-200;
  }
  
  .card {
    @apply bg-white rounded-lg shadow-md border border-gray-200 transition-all duration-200 hover:shadow-lg hover:-translate-y-1;
  }
  
  .badge {
    @apply inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium;
  }
  
  .badge-success {
    @apply bg-green-100 text-green-800;
  }
  
  .badge-warning {
    @apply bg-yellow-100 text-yellow-800;
  }
  
  .badge-error {
    @apply bg-red-100 text-red-800;
  }
  
  .badge-info {
    @apply bg-blue-100 text-blue-800;
  }
  
  .badge-ai {
    @apply bg-gradient-to-r from-purple-500 to-pink-500 text-white;
  }
}

@layer utilities {
  .text-gradient {
    @apply bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent;
  }
  
  .hero-gradient {
    @apply bg-gradient-to-br from-blue-600 via-purple-600 to-pink-600;
  }
}
EOF

# Create homepage
cat > nextjs-frontend/src/app/page.tsx << 'EOF'
import { Suspense } from 'react'
import HeroSection from '@/components/HeroSection'
import ProductGrid from '@/components/ProductGrid'
import AIStatusBanner from '@/components/AIStatusBanner'
import LoadingSpinner from '@/components/LoadingSpinner'

export default function HomePage() {
  return (
    <>
      <HeroSection />
      
      <section className="py-12 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <AIStatusBanner />
          
          <Suspense fallback={<LoadingSpinner />}>
            <ProductGrid />
          </Suspense>
        </div>
      </section>
    </>
  )
}
EOF

# Create components
cat > nextjs-frontend/src/components/Header.tsx << 'EOF'
'use client'

import Link from 'next/link'
import { ShoppingCart, Menu, X } from 'lucide-react'
import { useState } from 'react'

export default function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)

  return (
    <header className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <Link href="/" className="flex items-center space-x-2">
            <span className="text-2xl">🤖</span>
            <span className="text-xl font-bold text-gradient">
              AI E-commerce Store
            </span>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center space-x-8">
            <Link href="/" className="text-gray-700 hover:text-primary-600 transition-colors">
              Home
            </Link>
            <Link href="/products" className="text-gray-700 hover:text-primary-600 transition-colors">
              Products
            </Link>
            <Link href="/about" className="text-gray-700 hover:text-primary-600 transition-colors">
              About
            </Link>
          </nav>

          {/* Right side */}
          <div className="flex items-center space-x-4">
            {/* Cart */}
            <button className="relative p-2 text-gray-700 hover:text-primary-600 transition-colors">
              <ShoppingCart className="h-6 w-6" />
              <span className="absolute -top-1 -right-1 bg-primary-600 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                0
              </span>
            </button>

            {/* Mobile menu button */}
            <button
              className="md:hidden p-2 text-gray-700 hover:text-primary-600"
              onClick={() => setIsMenuOpen(!isMenuOpen)}
            >
              {isMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMenuOpen && (
          <div className="md:hidden border-t border-gray-200 py-4">
            <nav className="flex flex-col space-y-4">
              <Link href="/" className="text-gray-700 hover:text-primary-600 transition-colors">
                Home
              </Link>
              <Link href="/products" className="text-gray-700 hover:text-primary-600 transition-colors">
                Products
              </Link>
              <Link href="/about" className="text-gray-700 hover:text-primary-600 transition-colors">
                About
              </Link>
            </nav>
          </div>
        )}
      </div>
    </header>
  )
}
EOF

cat > nextjs-frontend/src/components/Footer.tsx << 'EOF'
export default function Footer() {
  return (
    <footer className="bg-gray-900 text-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="col-span-1 md:col-span-2">
            <div className="flex items-center space-x-2 mb-4">
              <span className="text-2xl">🤖</span>
              <span className="text-xl font-bold">AI E-commerce Platform</span>
            </div>
            <p className="text-gray-400 mb-4">
              Powered by artificial intelligence for automated product sourcing, 
              intelligent pricing, and market research.
            </p>
          </div>

          {/* Technology Stack */}
          <div>
            <h6 className="font-semibold mb-4">Technology Stack</h6>
            <ul className="space-y-2 text-gray-400">
              <li>🐘 PostgreSQL Database</li>
              <li>⚡ Next.js & React</li>
              <li>🚀 Express.js API</li>
              <li>🤖 Python AI Agent</li>
            </ul>
          </div>

          {/* Features */}
          <div>
            <h6 className="font-semibold mb-4">Features</h6>
            <ul className="space-y-2 text-gray-400">
              <li>✅ Real-time Product Import</li>
              <li>✅ Intelligent Pricing</li>
              <li>✅ Canadian Market Focus</li>
              <li>✅ Mobile Responsive</li>
            </ul>
          </div>
        </div>

        <hr className="my-8 border-gray-800" />
        
        <div className="text-center text-gray-400">
          <p>© 2024 AI E-commerce Platform. Built with ❤️ for Canadian entrepreneurs.</p>
        </div>
      </div>
    </footer>
  )
}
EOF

cat > nextjs-frontend/src/components/HeroSection.tsx << 'EOF'
export default function HeroSection() {
  return (
    <section className="hero-gradient text-white py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <div className="animate-fade-in">
          <h1 className="text-4xl md:text-6xl font-bold mb-6">
            🤖 AI-Powered E-commerce Platform
          </h1>
          <p className="text-xl md:text-2xl mb-8 text-blue-100">
            Discover amazing products sourced automatically by our AI agent from trusted suppliers worldwide
          </p>
          
          {/* Feature badges */}
          <div className="flex flex-wrap justify-center gap-4 mb-8">
            <span className="badge badge-ai">✨ AI-Powered</span>
            <span className="badge bg-white text-gray-900">🐘 PostgreSQL</span>
            <span className="badge bg-green-500 text-white">🇨🇦 Canadian Market</span>
            <span className="badge bg-yellow-500 text-white">⚡ Next.js SSR</span>
          </div>
          
          <a 
            href="#products" 
            className="btn-primary text-lg px-8 py-3 inline-block animate-pulse-slow"
          >
            Shop Now
          </a>
        </div>
      </div>
    </section>
  )
}
EOF

cat > nextjs-frontend/src/components/AIStatusBanner.tsx << 'EOF'
'use client'

import { useEffect, useState } from 'react'
import { Bot, CheckCircle, Clock } from 'lucide-react'

export default function AIStatusBanner() {
  const [productCount, setProductCount] = useState<number | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchProductCount = async () => {
      try {
        const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/products`)
        const products = await response.json()
        setProductCount(products.length)
      } catch (error) {
        console.error('Error fetching products:', error)
        setProductCount(0)
      } finally {
        setLoading(false)
      }
    }

    fetchProductCount()
  }, [])

  return (
    <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-8">
      <div className="flex items-center">
        <Bot className="h-6 w-6 text-blue-600 mr-3" />
        <div>
          <strong className="text-blue-900">AI Agent Status:</strong>
          {loading ? (
            <span className="ml-2 text-blue-700">
              <Clock className="inline h-4 w-4 mr-1" />
              Connecting to AI systems...
            </span>
          ) : productCount && productCount > 0 ? (
            <span className="ml-2 text-green-700">
              <CheckCircle className="inline h-4 w-4 mr-1" />
              Active - Found {productCount} products in database
            </span>
          ) : (
            <span className="ml-2 text-yellow-700">
              🤖 AI agent is importing products (runs every 15 minutes)
            </span>
          )}
        </div>
      </div>
    </div>
  )
}
EOF

cat > nextjs-frontend/src/components/ProductGrid.tsx << 'EOF'
import { fetchProducts } from '@/lib/api'
import ProductCard from './ProductCard'
import EmptyState from './EmptyState'

export default async function ProductGrid() {
  const products = await fetchProducts()

  if (!products || products.length === 0) {
    return <EmptyState />
  }

  return (
    <div className="animate-fade-in">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {products.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>
    </div>
  )
}
EOF

cat > nextjs-frontend/src/components/ProductCard.tsx << 'EOF'
import Image from 'next/image'
import { Star, ShoppingCart, Eye } from 'lucide-react'

interface Product {
  id: string
  title: string
  description: string | null
  sourcePrice: number
  marketPrice: number
  currency: string
  images: string[]
  category: string
  availability: boolean
  rating: number
  reviewsCount: number
  inventoryLevel: string
}

interface ProductCardProps {
  product: Product
}

export default function ProductCard({ product }: ProductCardProps) {
  const imageUrl = product.images[0] || 'https://via.placeholder.com/400x300?text=No+Image'
  
  const renderStars = (rating: number) => {
    return Array.from({ length: 5 }, (_, i) => (
      <Star
        key={i}
        className={`h-4 w-4 ${
          i < Math.floor(rating) ? 'text-yellow-400 fill-current' : 'text-gray-300'
        }`}
      />
    ))
  }

  return (
    <div className="card p-0 overflow-hidden animate-slide-up">
      {/* Sale badge */}
      {product.marketPrice < product.sourcePrice * 1.5 && (
        <div className="absolute top-2 right-2 z-10">
          <span className="badge badge-error">AI Priced</span>
        </div>
      )}

      {/* Product image */}
      <div className="relative h-48 bg-gray-100">
        <Image
          src={imageUrl}
          alt={product.title}
          fill
          className="object-cover"
          sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 25vw"
        />
      </div>

      {/* Product details */}
      <div className="p-4">
        {/* Category */}
        <span className="badge badge-info mb-2">{product.category}</span>

        {/* Title */}
        <h3 className="font-semibold text-lg mb-2 line-clamp-2">{product.title}</h3>

        {/* Rating */}
        <div className="flex items-center mb-2">
          <div className="flex">
            {renderStars(product.rating)}
          </div>
          <span className="text-sm text-gray-600 ml-1">({product.reviewsCount})</span>
        </div>

        {/* Price */}
        <div className="mb-3">
          <div className="text-xl font-bold text-green-600">
            ${product.marketPrice.toFixed(2)} {product.currency}
          </div>
          {product.sourcePrice !== product.marketPrice && (
            <div className="text-sm text-gray-500 line-through">
              Was: ${product.sourcePrice.toFixed(2)}
            </div>
          )}
        </div>

        {/* Availability */}
        <div className="mb-4">
          {product.availability ? (
            <span className="badge badge-success">✅ {product.inventoryLevel}</span>
          ) : (
            <span className="badge badge-error">❌ Out of Stock</span>
          )}
        </div>

        {/* Actions */}
        <div className="flex gap-2">
          {product.availability ? (
            <button className="btn-primary flex-1 flex items-center justify-center gap-2">
              <ShoppingCart className="h-4 w-4" />
              Add to Cart
            </button>
          ) : (
            <button className="btn-secondary flex-1" disabled>
              <span className="flex items-center justify-center gap-2">
                ❌ Out of Stock
              </span>
            </button>
          )}
          <button className="btn-secondary p-2">
            <Eye className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  )
}
EOF

cat > nextjs-frontend/src/components/EmptyState.tsx << 'EOF'
export default function EmptyState() {
  return (
    <div className="text-center py-16">
      <div className="mb-8">
        <span className="text-6xl">🤖</span>
      </div>
      <h3 className="text-2xl font-bold text-gray-900 mb-4">
        🤖 AI Agent is Working Hard!
      </h3>
      <p className="text-lg text-gray-600 mb-8 max-w-2xl mx-auto">
        Our artificial intelligence is currently importing products from suppliers around the world.
      </p>
      
      <div className="max-w-md mx-auto">
        <div className="card p-6">
          <h5 className="font-semibold mb-4">🔄 What's Happening?</h5>
          <ul className="text-left space-y-2 text-gray-600">
            <li>✅ PostgreSQL database is ready</li>
            <li>✅ Express.js API is connected</li>
            <li>🤖 Python AI agent is scraping products</li>
            <li>⏰ New products imported every 15 minutes</li>
          </ul>
          <hr className="my-4" />
          <p className="text-sm text-gray-500">
            <strong>Check back in a few minutes</strong> or watch the logs: 
            <code className="bg-gray-100 px-1 rounded ml-1">make logs-agent</code>
          </p>
        </div>
      </div>
    </div>
  )
}
EOF

cat > nextjs-frontend/src/components/LoadingSpinner.tsx << 'EOF'
export default function LoadingSpinner() {
  return (
    <div className="flex flex-col items-center justify-center py-16">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mb-4"></div>
      <h4 className="text-xl font-semibold text-gray-700">Loading Products from PostgreSQL...</h4>
      <p className="text-gray-500 mt-2">Our AI agent is fetching the latest products for you</p>
    </div>
  )
}
EOF

# Create API utilities
cat > nextjs-frontend/src/lib/api.ts << 'EOF'
const API_URL = process.env.API_URL || 'http://localhost:3001'

export interface Product {
  id: string
  title: string
  description: string | null
  sourcePrice: number
  marketPrice: number
  currency: string
  images: string[]
  category: string
  availability: boolean
  rating: number
  reviewsCount: number
  inventoryLevel: string
}

export async function fetchProducts(): Promise<Product[]> {
  try {
    const response = await fetch(`${API_URL}/api/products`, {
      cache: 'no-store', // Always fetch fresh data
    })
    
    if (!response.ok) {
      throw new Error('Failed to fetch products')
    }
    
    return await response.json()
  } catch (error) {
    console.error('Error fetching products:', error)
    return []
  }
}

export async function fetchProduct(id: string): Promise<Product | null> {
  try {
    const response = await fetch(`${API_URL}/api/products/${id}`, {
      cache: 'no-store',
    })
    
    if (!response.ok) {
      return null
    }
    
    return await response.json()
  } catch (error) {
    console.error('Error fetching product:', error)
    return null
  }
}
EOF

# Create Next.js Dockerfile
cat > nextjs-frontend/Dockerfile << 'EOF'
FROM node:18-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Create logs directory
RUN mkdir -p logs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD curl -f http://localhost:3000/ || exit 1

# Expose port
EXPOSE 3000

# Start in development mode
CMD ["npm", "run", "dev"]
EOF

print_status "Next.js Frontend with React SSR created"

print_section "Creating updated Python AI Agent..."

# Update Python agent for Node.js API compatibility
cat > python-agent/main.py << 'EOF'
#!/usr/bin/env python3
"""
Enhanced Python AI Agent for E-commerce Platform with Node.js API
"""

import asyncio
import aiohttp
import json
import logging
import os
import time
import random
from dataclasses import dataclass, asdict
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/agent.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class ProductData:
    """Enhanced product data structure for Node.js API"""
    sourceProductId: str
    sourceSite: str
    title: str
    description: str
    sourcePrice: float
    currency: str
    images: List[str]
    category: str
    availability: bool
    supplierInfo: dict
    specifications: Dict[str, Any]
    reviewsCount: int
    rating: float
    shippingInfo: Dict[str, Any]
    inventoryLevel: str

class NodeJSProductScraper:
    """Node.js API-compatible product scraper"""
    
    def __init__(self, api_base_url: str = "http://express-api:3001"):
        self.api_base_url = api_base_url
        self.session = None
        
    async def __aenter__(self):
        timeout = aiohttp.ClientTimeout(total=30)
        self.session = aiohttp.ClientSession(timeout=timeout)
        return self
        
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()

    async def scrape_demo_products(self) -> List[ProductData]:
        """Demo scraping with realistic data for Node.js API testing - 12 diverse products"""
        logger.info("Starting Node.js API demo product scraping...")
        
        await asyncio.sleep(2)  # Simulate scraping delay
        
        mock_products = [
            ProductData(
                sourceProductId="NODE001",
                sourceSite="nodejs-demo",
                title="🎧 Premium Wireless Noise-Cancelling Headphones",
                description="Professional-grade wireless headphones with advanced noise cancellation technology. Perfect for music production, gaming, and daily use with 30-hour battery life.",
                sourcePrice=45.99,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400",
                    "https://images.unsplash.com/photo-1484704849700-f032a568e944?w=400"
                ],
                category="Electronics",
                availability=True,
                supplierInfo={
                    "rating": 4.8, 
                    "location": "Seoul", 
                    "shipping_time": "5-10 days",
                    "min_order": 1,
                    "supplier_name": "AudioTech Pro"
                },
                specifications={
                    "Battery": "30 hours", 
                    "Connectivity": "Bluetooth 5.2", 
                    "Noise Cancellation": "Advanced ANC",
                    "Water Resistance": "IPX4",
                    "Weight": "290g",
                    "Driver": "40mm Dynamic"
                },
                reviewsCount=2850,
                rating=4.8,
                shippingInfo={"cost": 0, "method": "Free express shipping", "estimated_days": 7},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE002", 
                sourceSite="nodejs-demo",
                title="💡 Smart WiFi RGB LED Strip Kit 10M",
                description="Extended 10-meter smart LED strip with app control, voice assistant compatibility, and music sync. Create stunning ambient lighting for any room or occasion.",
                sourcePrice=28.50,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400",
                    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400"
                ],
                category="Home & Garden",
                availability=True,
                supplierInfo={
                    "rating": 4.6, 
                    "location": "Shanghai", 
                    "shipping_time": "7-14 days",
                    "min_order": 1,
                    "supplier_name": "BrightHome Electronics"
                },
                specifications={
                    "Length": "10 meters", 
                    "Colors": "16 million RGB", 
                    "Control": "WiFi + Bluetooth",
                    "Power": "36W",
                    "Voltage": "12V",
                    "Compatibility": "Alexa, Google, App"
                },
                reviewsCount=1890,
                rating=4.6,
                shippingInfo={"cost": 0, "method": "Free shipping", "estimated_days": 10},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE003",
                sourceSite="nodejs-demo",
                title="📱 Magnetic Wireless Charger Stand Pro",
                description="Premium magnetic wireless charging stand compatible with MagSafe. Features adjustable viewing angles and fast 15W charging for optimal convenience.",
                sourcePrice=19.99,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1609592173003-7044a27c4de8?w=400",
                    "https://images.unsplash.com/photo-1556656793-08538906a9f8?w=400"
                ],
                category="Accessories",
                availability=True,
                supplierInfo={
                    "rating": 4.7, 
                    "location": "Taipei", 
                    "shipping_time": "6-12 days",
                    "min_order": 1,
                    "supplier_name": "ChargeTech Solutions"
                },
                specifications={
                    "Charging Speed": "15W Fast Wireless", 
                    "Compatibility": "MagSafe + Qi", 
                    "Adjustable": "Multi-angle",
                    "Material": "Premium Aluminum",
                    "Safety": "Over-temp Protection",
                    "LED": "Status Indicator"
                },
                reviewsCount=1250,
                rating=4.7,
                shippingInfo={"cost": 2.99, "method": "Standard shipping", "estimated_days": 9},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE004",
                sourceSite="nodejs-demo",
                title="🔋 Ultra-Fast Portable Power Bank 20000mAh",
                description="High-capacity portable charger with 65W USB-C PD fast charging. Can charge laptops, phones, and tablets simultaneously with digital display.",
                sourcePrice=35.75,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1609592173003-7044a27c4de8?w=400"
                ],
                category="Electronics",
                availability=True,
                supplierInfo={
                    "rating": 4.5, 
                    "location": "Shenzhen", 
                    "shipping_time": "8-15 days",
                    "min_order": 1,
                    "supplier_name": "PowerMax Industries"
                },
                specifications={
                    "Capacity": "20,000mAh", 
                    "Output": "65W USB-C PD", 
                    "Ports": "3x USB + 1x USB-C",
                    "Display": "Digital LED",
                    "Fast Charging": "PD 3.0 + QC 4.0",
                    "Safety": "Multi-Protection"
                },
                reviewsCount=1650,
                rating=4.5,
                shippingInfo={"cost": 4.99, "method": "Express shipping", "estimated_days": 8},
                inventoryLevel="Limited Stock"
            ),
            ProductData(
                sourceProductId="NODE005",
                sourceSite="nodejs-demo",
                title="🎮 Ergonomic Gaming Mouse with RGB",
                description="Professional gaming mouse with 12000 DPI sensor, customizable RGB lighting, and programmable buttons. Designed for competitive gaming and productivity.",
                sourcePrice=24.99,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1527814050087-3793815479db?w=400"
                ],
                category="Electronics",
                availability=True,
                supplierInfo={
                    "rating": 4.4, 
                    "location": "Hong Kong", 
                    "shipping_time": "5-12 days",
                    "min_order": 1,
                    "supplier_name": "GameGear Pro"
                },
                specifications={
                    "DPI": "12,000 adjustable", 
                    "Buttons": "7 programmable", 
                    "RGB": "16.8M colors",
                    "Polling Rate": "1000Hz",
                    "Weight": "85g",
                    "Cable": "Braided USB-C"
                },
                reviewsCount=980,
                rating=4.4,
                shippingInfo={"cost": 3.50, "method": "Standard shipping", "estimated_days": 8},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE006",
                sourceSite="nodejs-demo",
                title="🏠 Smart Home Security Camera 4K",
                description="Advanced 4K security camera with AI motion detection, night vision, and cloud storage. Perfect for monitoring your home with smartphone alerts.",
                sourcePrice=89.99,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400"
                ],
                category="Home & Garden",
                availability=True,
                supplierInfo={
                    "rating": 4.6, 
                    "location": "Beijing", 
                    "shipping_time": "10-18 days",
                    "min_order": 1,
                    "supplier_name": "SecureVision Tech"
                },
                specifications={
                    "Resolution": "4K Ultra HD", 
                    "Night Vision": "Full Color", 
                    "Storage": "Cloud + Local",
                    "AI Features": "Person/Vehicle Detection",
                    "Weather Resistant": "IP66",
                    "Power": "PoE or DC"
                },
                reviewsCount=2400,
                rating=4.6,
                shippingInfo={"cost": 0, "method": "Free shipping", "estimated_days": 14},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE007",
                sourceSite="nodejs-demo",
                title="☕ Electric Coffee Grinder Pro",
                description="Premium burr coffee grinder with 40 grind settings and timer. Perfect for espresso, drip, and French press coffee preparation.",
                sourcePrice=67.50,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400"
                ],
                category="Kitchen",
                availability=True,
                supplierInfo={
                    "rating": 4.8, 
                    "location": "Milan", 
                    "shipping_time": "12-20 days",
                    "min_order": 1,
                    "supplier_name": "CoffeeMax Europe"
                },
                specifications={
                    "Grind Settings": "40 precise levels", 
                    "Burr Type": "Conical steel", 
                    "Timer": "Digital with memory",
                    "Capacity": "350g beans",
                    "Motor": "150W low-speed",
                    "Noise Level": "Ultra-quiet"
                },
                reviewsCount=890,
                rating=4.8,
                shippingInfo={"cost": 12.99, "method": "International express", "estimated_days": 16},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE008",
                sourceSite="nodejs-demo",
                title="🎒 Waterproof Travel Backpack 35L",
                description="Durable waterproof backpack with laptop compartment, USB charging port, and anti-theft design. Perfect for travel and daily commuting.",
                sourcePrice=42.00,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400"
                ],
                category="Travel",
                availability=True,
                supplierInfo={
                    "rating": 4.3, 
                    "location": "Vietnam", 
                    "shipping_time": "14-25 days",
                    "min_order": 1,
                    "supplier_name": "AdventureGear Co"
                },
                specifications={
                    "Capacity": "35 liters", 
                    "Material": "Waterproof nylon", 
                    "Laptop Size": "Up to 17 inches",
                    "USB Port": "External charging",
                    "Security": "Hidden zippers",
                    "Weight": "1.2kg"
                },
                reviewsCount=1560,
                rating=4.3,
                shippingInfo={"cost": 8.99, "method": "Economy shipping", "estimated_days": 20},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE009",
                sourceSite="nodejs-demo",
                title="🌱 Indoor Herb Garden Kit",
                description="Complete hydroponic herb growing system with LED grow lights. Grow fresh basil, mint, and parsley year-round in your kitchen.",
                sourcePrice=56.25,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400"
                ],
                category="Home & Garden",
                availability=True,
                supplierInfo={
                    "rating": 4.5, 
                    "location": "Netherlands", 
                    "shipping_time": "8-15 days",
                    "min_order": 1,
                    "supplier_name": "GreenGrow Systems"
                },
                specifications={
                    "Growing Pods": "12 herb slots", 
                    "LED Lights": "Full spectrum", 
                    "Water Tank": "4 liter capacity",
                    "Growth Height": "Adjustable 24cm",
                    "Power": "28W energy efficient",
                    "Included": "Seeds + nutrients"
                },
                reviewsCount=750,
                rating=4.5,
                shippingInfo={"cost": 15.99, "method": "Express international", "estimated_days": 12},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE010",
                sourceSite="nodejs-demo",
                title="🏋️ Adjustable Dumbbells Set 40kg",
                description="Space-saving adjustable dumbbell set with quick-change plates. Perfect for home gym workouts with weight range from 2.5kg to 20kg per dumbbell.",
                sourcePrice=129.99,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400"
                ],
                category="Fitness",
                availability=True,
                supplierInfo={
                    "rating": 4.7, 
                    "location": "Germany", 
                    "shipping_time": "15-25 days",
                    "min_order": 1,
                    "supplier_name": "FitnessPro GmbH"
                },
                specifications={
                    "Weight Range": "2.5kg - 20kg each", 
                    "Material": "Cast iron + rubber", 
                    "Handle": "Ergonomic grip",
                    "Plates": "Quick-lock system",
                    "Storage": "Compact design",
                    "Warranty": "2 years"
                },
                reviewsCount=640,
                rating=4.7,
                shippingInfo={"cost": 25.99, "method": "Heavy item shipping", "estimated_days": 20},
                inventoryLevel="Limited Stock"
            ),
            ProductData(
                sourceProductId="NODE011",
                sourceSite="nodejs-demo",
                title="📚 E-Reader with Backlight",
                description="6-inch e-ink display e-reader with adjustable warm light, waterproof design, and 8-week battery life. Perfect for reading anywhere.",
                sourcePrice=78.90,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1481178733974-87d62cd0cf34?w=400"
                ],
                category="Electronics",
                availability=True,
                supplierInfo={
                    "rating": 4.4, 
                    "location": "Japan", 
                    "shipping_time": "10-18 days",
                    "min_order": 1,
                    "supplier_name": "DigitalRead Tech"
                },
                specifications={
                    "Screen": "6 inch E-ink", 
                    "Resolution": "300 PPI", 
                    "Backlight": "Adjustable warm",
                    "Storage": "8GB (thousands of books)",
                    "Battery": "8 weeks",
                    "Waterproof": "IPX8 rated"
                },
                reviewsCount=1120,
                rating=4.4,
                shippingInfo={"cost": 9.99, "method": "Air mail", "estimated_days": 14},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE012",
                sourceSite="nodejs-demo",
                title="🎨 Digital Drawing Tablet with Pen",
                description="Professional 10-inch drawing tablet with 8192 pressure levels and battery-free stylus. Perfect for digital art, design, and online teaching.",
                sourcePrice=95.00,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400"
                ],
                category="Electronics",
                availability=True,
                supplierInfo={
                    "rating": 4.6, 
                    "location": "South Korea", 
                    "shipping_time": "7-14 days",
                    "min_order": 1,
                    "supplier_name": "ArtTech Digital"
                },
                specifications={
                    "Active Area": "10 x 6.25 inches", 
                    "Pressure Levels": "8192", 
                    "Pen": "Battery-free stylus",
                    "Compatibility": "Windows, Mac, Linux",
                    "Express Keys": "8 customizable",
                    "Software": "Multiple art programs"
                },
                reviewsCount=2890,
                rating=4.6,
                shippingInfo={"cost": 12.99, "method": "Express shipping", "estimated_days": 10},
                inventoryLevel="In Stock"
            )
        ]
        
        logger.info(f"Successfully scraped {len(mock_products)} products for Node.js API")
        return mock_products

    async def send_to_api(self, products: List[ProductData]) -> bool:
        """Send scraped products to Node.js API"""
        if not self.session:
            logger.error("Session not initialized")
            return False
            
        try:
            products_json = [asdict(product) for product in products]
            
            # Send products to Node.js API
            async with self.session.post(
                f"{self.api_base_url}/api/products/bulk-import",
                json=products_json,
                headers={
                    'Content-Type': 'application/json',
                    'User-Agent': 'NodeJS-AI-Agent/1.0'
                },
                ssl=False
            ) as response:
                if response.status == 200:
                    result = await response.json()
                    logger.info(f"Successfully sent {len(products)} products to Node.js API: {result}")
                    return True
                else:
                    error_text = await response.text()
                    logger.error(f"Node.js API request failed: {response.status} - {error_text}")
                    return False
                    
        except Exception as e:
            logger.error(f"Failed to send data to Node.js API: {e}")
            return False

async def main():
    """Main execution loop for Node.js platform"""
    logger.info("🚀 Starting Node.js AI Agent System...")
    
    cycle_count = 0
    
    while True:
        try:
            cycle_count += 1
            logger.info(f"=== ⚡ Node.js Cycle {cycle_count} ===")
            
            # Use context manager for scraper
            async with NodeJSProductScraper() as scraper:
                # Scrape products for Node.js API
                logger.info("🤖 Scraping products for Node.js API...")
                all_products = await scraper.scrape_demo_products()
                
                # Send to Node.js API
                logger.info("📤 Sending data to Node.js API...")
                api_success = await scraper.send_to_api(all_products)
                
                # Summary
                logger.info(f"""
=== ⚡ Node.js Cycle {cycle_count} Summary ===
Products processed: {len(all_products)}
Node.js API sync: {'✅ Success' if api_success else '❌ Failed'}
Database: PostgreSQL via Prisma
Frontend: Next.js with React SSR
Next cycle in 15 minutes...
==========================================
""")
            
            # Wait before next cycle (15 minutes)
            logger.info("⏳ Waiting 15 minutes before next cycle...")
            await asyncio.sleep(900)
            
        except KeyboardInterrupt:
            logger.info("🛑 Node.js Agent stopped by user")
            break
        except Exception as e:
            logger.error(f"💥 Error in Node.js main loop: {e}")
            logger.info("🔄 Retrying in 1 minute...")
            await asyncio.sleep(60)

if __name__ == "__main__":
    # Ensure logs directory exists
    os.makedirs('logs', exist_ok=True)
    
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("🏁 Node.js AI Agent shutdown complete")
    except Exception as e:
        logger.error(f"💥 Fatal error: {e}")
        sys.exit(1)
EOF

# Create Python requirements.txt
cat > python-agent/requirements.txt << 'EOF'
# Core dependencies for AI agent (M4 Mac Compatible)
aiohttp==3.9.1
python-dotenv==1.0.0
requests==2.31.0
psycopg2-binary==2.9.9
redis==5.0.1
structlog==23.2.0
EOF

# Create Python agent Dockerfile
cat > python-agent/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create logs directory
RUN mkdir -p logs

# Health check
HEALTHCHECK --interval=60s --timeout=30s --start-period=120s \
  CMD python -c "import requests; requests.get('http://express-api:3001/health', timeout=10)" || exit 1

# Run the agent
CMD ["python", "main.py"]
EOF

print_status "Updated Python AI Agent for Node.js created"

print_section "Creating Node.js optimized Docker Compose..."

# Create Docker Compose for Node.js stack with M4 Mac optimizations (FIXED)
cat > docker-compose.yml << 'EOF'
services:
  # =============================================================================
  # DATABASE SERVICES - PostgreSQL (M4 Mac ARM64 Optimized)
  # =============================================================================
  
  postgres:
    image: postgres:15-alpine
    platform: linux/arm64/v8
    container_name: ecommerce-postgres
    environment:
      - POSTGRES_DB=EcommerceAI
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=YourStrong@Passw0rd123!
      - POSTGRES_INITDB_ARGS=--encoding=UTF-8 --lc-collate=C --lc-ctype=C
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./sql-scripts:/docker-entrypoint-initdb.d
    networks:
      - ecommerce-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d EcommerceAI"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    restart: unless-stopped
    # M4 Mac optimizations
    shm_size: 256mb
    command: >
      postgres
      -c shared_buffers=256MB
      -c max_connections=200
      -c work_mem=4MB
      -c maintenance_work_mem=64MB
      -c effective_cache_size=1GB

  redis:
    image: redis:7-alpine
    platform: linux/arm64/v8
    container_name: ecommerce-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - ecommerce-network
    command: redis-server --appendonly yes --requirepass "RedisPass123!" --maxmemory 128mb --maxmemory-policy allkeys-lru
    healthcheck:
      test: ["CMD-SHELL", "redis-cli -a RedisPass123! ping || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 10s
    restart: unless-stopped

  # =============================================================================
  # NODE.JS APPLICATION SERVICES (M4 Mac ARM64 Optimized)
  # =============================================================================

  express-api:
    build:
      context: ./express-api
      dockerfile: Dockerfile
      platforms:
        - linux/arm64/v8
    platform: linux/arm64/v8
    container_name: ecommerce-express-api
    environment:
      - NODE_ENV=development
      - API_PORT=3001
      - DATABASE_URL=postgresql://postgres:YourStrong@Passw0rd123!@postgres:5432/EcommerceAI?schema=public
      - REDIS_URL=redis://redis:6379
      - REDIS_PASSWORD=RedisPass123!
      - JWT_SECRET=nodejs-super-secret-jwt-key-that-is-exactly-256-bits-long-for-security-2024
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY:-sk_test_default}
      - STRIPE_PUBLISHABLE_KEY=${STRIPE_PUBLISHABLE_KEY:-pk_test_default}
      - STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET:-whsec_default}
      # M4 Mac Node.js optimizations
      - UV_THREADPOOL_SIZE=16
      - NODE_OPTIONS=--max-old-space-size=2048
    ports:
      - "3001:3001"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - ecommerce-network
    volumes:
      - ./express-api/logs:/app/logs
      - ./express-api/src:/app/src
      - ./express-api/prisma:/app/prisma
      - node_modules_api:/app/node_modules
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3001/health || exit 1"]
      interval: 30s
      timeout: 15s
      retries: 5
      start_period: 180s
    restart: unless-stopped

  nextjs-frontend:
    build:
      context: ./nextjs-frontend
      dockerfile: Dockerfile
      platforms:
        - linux/arm64/v8
    platform: linux/arm64/v8
    container_name: ecommerce-nextjs-frontend
    environment:
      - NODE_ENV=development
      - PORT=3000
      - API_URL=http://express-api:3001
      - NEXT_PUBLIC_API_URL=http://localhost:3001
      - STRIPE_PUBLISHABLE_KEY=${STRIPE_PUBLISHABLE_KEY:-pk_test_default}
      # M4 Mac Next.js optimizations
      - NEXT_TELEMETRY_DISABLED=1
      - NODE_OPTIONS=--max-old-space-size=2048
    ports:
      - "3000:3000"
    depends_on:
      express-api:
        condition: service_healthy
    networks:
      - ecommerce-network
    volumes:
      - ./nextjs-frontend/logs:/app/logs
      - ./nextjs-frontend/src:/app/src
      - ./nextjs-frontend/public:/app/public
      - node_modules_frontend:/app/node_modules
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/ || exit 1"]
      interval: 15s
      timeout: 10s
      retries: 3
      start_period: 60s
    restart: unless-stopped

  python-agent:
    build:
      context: ./python-agent
      dockerfile: Dockerfile
      platforms:
        - linux/arm64/v8
    platform: linux/arm64/v8
    container_name: ecommerce-python-agent
    environment:
      - API_BASE_URL=http://express-api:3001
      - REDIS_URL=redis:6379,password=RedisPass123!
      - ENABLE_REAL_SCRAPING=true
      - ENABLE_MARKET_RESEARCH=true
      - PYTHON_ENV=development
      - LOG_LEVEL=INFO
      # M4 Mac Python optimizations
      - PYTHONUNBUFFERED=1
      - PYTHONDONTWRITEBYTECODE=1
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      express-api:
        condition: service_healthy
    networks:
      - ecommerce-network
    volumes:
      - ./python-agent/logs:/app/logs
      - ./python-agent/data:/app/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "python -c 'import requests; requests.get(\"http://express-api:3001/health\", timeout=10)' || exit 1"]
      interval: 30s
      timeout: 15s
      retries: 3
      start_period: 120s

  # =============================================================================
  # MONITORING SERVICES (M4 Mac Optimized)
  # =============================================================================

  prometheus:
    image: prom/prometheus:latest
    platform: linux/arm64/v8
    container_name: ecommerce-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=7d'
      - '--web.enable-lifecycle'
      - '--storage.tsdb.wal-compression'
    networks:
      - ecommerce-network
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    platform: linux/arm64/v8
    container_name: ecommerce-grafana
    ports:
      - "3002:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_SECURITY_ALLOW_EMBEDDING=true
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
    networks:
      - ecommerce-network
    restart: unless-stopped

# =============================================================================
# VOLUMES (M4 Mac Optimized)
# =============================================================================

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  prometheus_data:
    driver: local
  grafana_data:
    driver: local
  # Node.js module caching for M4 Mac performance
  node_modules_api:
    driver: local
  node_modules_frontend:
    driver: local

# =============================================================================
# NETWORKS (Fixed - Simple Bridge Network)
# =============================================================================

networks:
  ecommerce-network:
    driver: bridge
EOF

print_status "Node.js optimized Docker Compose created"

print_section "Creating updated Makefile for Node.js stack..."

# Create updated Makefile
cat > Makefile << 'EOF'
# AI-Powered E-commerce Platform - Management Commands (Node.js Version)

.PHONY: help setup build up down logs clean restart status backup restore test dev prod quick-start

# Default target
help: ## Show this help message
	@echo 'Complete AI-Powered E-commerce Platform (Node.js + Next.js + Express.js)'
	@echo
	@echo 'Usage:'
	@echo '  make [command]'
	@echo
	@echo 'Setup Commands:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $1, $2}' $(MAKEFILE_LIST)

setup: ## Initial project setup (copy env file, create directories)
	@echo "🔧 Setting up Complete AI-Powered E-commerce Platform (Node.js Version)..."
	@mkdir -p python-agent/logs python-agent/data
	@mkdir -p express-api/logs
	@mkdir -p nextjs-frontend/logs
	@mkdir -p nginx/logs
	@mkdir -p ssl-certs
	@mkdir -p backups
	@echo "✅ Created all necessary directories"
	@echo "📝 Ready to deploy!"

dev: ## Start all services in development mode
	@echo "🚀 Starting complete Node.js development environment (M4 Mac Optimized)..."
	@echo "📂 Creating data directories for M4 Mac performance..."
	@mkdir -p data/postgres
	@docker-compose up -d --build
	@echo "⏳ Waiting for services to be ready (M4 Mac may need extra time)..."
	@sleep 120
	@echo "✅ Development environment started!"
	@echo "📱 Access your applications:"
	@echo "   🛍️  Frontend:    http://localhost:3000 (Next.js with React SSR)"
	@echo "   🔧 API:         http://localhost:3001"
	@echo "   📊 Grafana:     http://localhost:3002 (admin/admin123)"
	@echo "   🐘 Database:    PostgreSQL on localhost:5432"

m4-dev: ## Start services with enhanced M4 Mac optimizations
	@echo "🚀 Starting development environment with M4 Mac optimizations..."
	@echo "🍃 Optimizing for Apple Silicon M4..."
	@mkdir -p data/postgres
	@export DOCKER_BUILDKIT=1 && export COMPOSE_DOCKER_CLI_BUILD=1
	@docker-compose build --parallel
	@docker-compose up -d
	@echo "⏳ Waiting longer for M4 Mac services to initialize..."
	@sleep 150
	@echo "✅ M4 Mac optimized environment started!"
	@echo "📱 Access your applications:"
	@echo "   🛍️  Frontend:    http://localhost:3000 (Next.js SSR)"
	@echo "   🔧 API:         http://localhost:3001 (Express.js + TypeScript)"
	@echo "   📊 Grafana:     http://localhost:3002 (admin/admin123)"

quick-start: setup m4-dev ## Quick start for new users (M4 Mac optimized)
	@echo "🎉 Quick start completed!"
	@echo "Your Complete AI-powered e-commerce platform (Node.js) is now running."
	@echo "🎨 Beautiful Next.js frontend with React SSR at http://localhost:3000"

health-check: ## Perform health checks on all services
	@echo "🏥 Performing health checks..."
	@if curl -f http://localhost:3001/health > /dev/null 2>&1; then echo "✅ Express.js API is healthy"; else echo "❌ API health check failed"; fi
	@if curl -f http://localhost:3000/ > /dev/null 2>&1; then echo "✅ Next.js Frontend is healthy"; else echo "❌ Frontend health check failed"; fi
	@if docker exec ecommerce-postgres pg_isready -U postgres > /dev/null 2>&1; then echo "✅ PostgreSQL is healthy"; else echo "❌ PostgreSQL health check failed"; fi

m4-check: ## Check M4 Mac compatibility and performance
	@echo "🔍 M4 Mac Compatibility Check:"
	@echo "Docker version:"
	@docker --version
	@echo "Docker Compose version:"
	@docker-compose --version
	@echo "Platform architecture:"
	@docker info | grep Architecture || echo "Architecture info not available"
	@echo "Available platforms:"
	@docker buildx ls
	@echo "Current containers:"
	@docker-compose ps
	@echo "M4 Mac optimization status:"
	@if docker info | grep -q "aarch64"; then echo "✅ ARM64 architecture detected - M4 Mac optimized"; else echo "⚠️  Non-ARM64 architecture detected"; fi

db-status: ## Check database status and tables
	@echo "🐘 PostgreSQL Database Status:"
	@echo "Database connection:"
	@docker exec ecommerce-postgres pg_isready -U postgres -d EcommerceAI || echo "❌ Database not ready"
	@echo "Tables in database:"
	@docker exec ecommerce-postgres psql -U postgres -d EcommerceAI -c "\\dt" 2>/dev/null || echo "No tables found"
	@echo "Product count:"
	@docker exec ecommerce-postgres psql -U postgres -d EcommerceAI -c "SELECT COUNT(*) FROM products;" 2>/dev/null || echo "Products table not accessible"

db-products: ## Show products in database
	@echo "📦 Products in Database:"
	@docker exec ecommerce-postgres psql -U postgres -d EcommerceAI -c "SELECT id, title, \"sourcePrice\", \"marketPrice\", category FROM products LIMIT 10;" 2>/dev/null || echo "No products found or table doesn't exist"

db-reset: ## Reset PostgreSQL database (WARNING: deletes all data)
	@echo "⚠️  WARNING: This will delete ALL database data!"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$confirm" = "yes" ] || exit 1
	@docker-compose down postgres
	@docker volume rm ${PROJECT_NAME}_postgres_data || true
	@docker-compose up -d postgres
	@echo "✅ PostgreSQL database reset completed"

db-init: ## Initialize database schema with Prisma
	@echo "🔄 Initializing database schema with Prisma..."
	@docker exec ecommerce-express-api npx prisma db push
	@echo "✅ Database schema initialized"

test-api: ## Test API endpoints
	@echo "🧪 Testing API endpoints..."
	@echo "Health check:"
	@curl -f http://localhost:3001/health 2>/dev/null && echo " ✅" || echo " ❌"
	@echo "Products endpoint:"
	@curl -f http://localhost:3001/api/products 2>/dev/null | head -c 100 && echo "... ✅" || echo " ❌"

test-import: ## Test product import with sample data
	@echo "📤 Testing product import..."
	@curl -X POST http://localhost:3001/api/products/bulk-import \
		-H "Content-Type: application/json" \
		-d '[{"sourceProductId":"TEST001","sourceSite":"manual-test","title":"🧪 Test Product","description":"Manual test product for debugging","sourcePrice":15.99,"currency":"CAD","images":["https://via.placeholder.com/400?text=Test+Product"],"category":"Test","availability":true,"supplierInfo":{},"specifications":{},"reviewsCount":1,"rating":5.0,"shippingInfo":{},"inventoryLevel":"In Stock"}]' \
		2>/dev/null && echo "✅ Import test successful" || echo "❌ Import test failed"

fix-api: ## Fix Express API startup issues
	@echo "🔧 Fixing Express API startup issues..."
	@echo "Stopping API container..."
	@docker-compose stop express-api
	@echo "Removing API container..."
	@docker-compose rm -f express-api
	@echo "Rebuilding API container..."
	@docker-compose build --no-cache express-api
	@echo "Initializing database schema manually..."
	@docker-compose up -d postgres redis
	@sleep 20
	@docker-compose run --rm express-api npx prisma db push --force-reset || echo "Schema push failed, will retry at startup"
	@echo "Starting API container..."
	@docker-compose up -d express-api
	@echo "Waiting for API to be ready..."
	@sleep 60
	@echo "Testing API health..."
	@curl -f http://localhost:3001/health && echo " ✅ API is healthy" || echo " ⚠️  API still not ready, check logs with: make logs-api"

debug-api: ## Debug Express API issues
	@echo "🔍 Debugging Express API issues..."
	@echo "=== Container Status ==="
	@docker-compose ps express-api
	@echo ""
	@echo "=== Recent API Logs ==="
	@docker-compose logs express-api --tail 20
	@echo ""
	@echo "=== Database Connection ==="
	@docker exec ecommerce-postgres pg_isready -U postgres -d EcommerceAI || echo "Database not ready"
	@echo ""
	@echo "=== Health Check ==="
	@curl -f http://localhost:3001/health 2>/dev/null && echo "✅ API responding" || echo "❌ API not responding"
	@echo ""
	@echo "=== Port Status ==="
	@netstat -an | grep 3001 || echo "Port 3001 not in use"

fix-missing-files: ## Fix common missing files
	@echo "🔧 Fixing missing files..."
	@if [ ! -f "python-agent/requirements.txt" ]; then \
		echo "Creating missing requirements.txt..."; \
		echo "aiohttp==3.9.1" > python-agent/requirements.txt; \
		echo "python-dotenv==1.0.0" >> python-agent/requirements.txt; \
		echo "requests==2.31.0" >> python-agent/requirements.txt; \
		echo "psycopg2-binary==2.9.9" >> python-agent/requirements.txt; \
		echo "redis==5.0.1" >> python-agent/requirements.txt; \
		echo "structlog==23.2.0" >> python-agent/requirements.txt; \
		echo "✅ Created python-agent/requirements.txt"; \
	fi
	@if [ ! -f "monitoring/prometheus/prometheus.yml" ]; then \
		mkdir -p monitoring/prometheus; \
		echo "global:" > monitoring/prometheus/prometheus.yml; \
		echo "  scrape_interval: 15s" >> monitoring/prometheus/prometheus.yml; \
		echo "scrape_configs:" >> monitoring/prometheus/prometheus.yml; \
		echo "  - job_name: 'express-api'" >> monitoring/prometheus/prometheus.yml; \
		echo "    static_configs:" >> monitoring/prometheus/prometheus.yml; \
		echo "      - targets: ['express-api:3001']" >> monitoring/prometheus/prometheus.yml; \
		echo "✅ Created monitoring/prometheus/prometheus.yml"; \
	fi
	@echo "✅ Missing files check completed"

populate-products: ## Populate database with 12 sample products
	@echo "🌱 Populating database with sample products..."
	@curl -X POST http://localhost:3001/api/products/bulk-import \
		-H "Content-Type: application/json" \
		-d '[{"sourceProductId":"SAMPLE001","sourceSite":"sample","title":"🎧 Wireless Bluetooth Headphones","description":"High-quality wireless headphones with noise cancellation","sourcePrice":79.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400"],"category":"Electronics","availability":true,"supplierInfo":{"rating":4.5},"specifications":{"Battery":"20 hours"},"reviewsCount":150,"rating":4.5,"shippingInfo":{},"inventoryLevel":"In Stock"},{"sourceProductId":"SAMPLE002","sourceSite":"sample","title":"💡 Smart LED Bulb","description":"WiFi-enabled smart LED bulb with color changing","sourcePrice":24.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400"],"category":"Home & Garden","availability":true,"supplierInfo":{"rating":4.3},"specifications":{"Wattage":"9W"},"reviewsCount":89,"rating":4.3,"shippingInfo":{},"inventoryLevel":"In Stock"},{"sourceProductId":"SAMPLE003","sourceSite":"sample","title":"📱 Phone Stand","description":"Adjustable aluminum phone stand","sourcePrice":19.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1556656793-08538906a9f8?w=400"],"category":"Accessories","availability":true,"supplierInfo":{"rating":4.7},"specifications":{"Material":"Aluminum"},"reviewsCount":203,"rating":4.7,"shippingInfo":{},"inventoryLevel":"In Stock"},{"sourceProductId":"SAMPLE004","sourceSite":"sample","title":"🔋 Power Bank 10000mAh","description":"Portable power bank with fast charging","sourcePrice":34.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1609592173003-7044a27c4de8?w=400"],"category":"Electronics","availability":true,"supplierInfo":{"rating":4.4},"specifications":{"Capacity":"10000mAh"},"reviewsCount":176,"rating":4.4,"shippingInfo":{},"inventoryLevel":"In Stock"},{"sourceProductId":"SAMPLE005","sourceSite":"sample","title":"🎮 Gaming Mouse","description":"RGB gaming mouse with high DPI","sourcePrice":29.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1527814050087-3793815479db?w=400"],"category":"Electronics","availability":true,"supplierInfo":{"rating":4.6},"specifications":{"DPI":"8000"},"reviewsCount":134,"rating":4.6,"shippingInfo":{},"inventoryLevel":"In Stock"},{"sourceProductId":"SAMPLE006","sourceSite":"sample","title":"☕ Coffee Mug","description":"Insulated travel coffee mug","sourcePrice":16.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400"],"category":"Kitchen","availability":true,"supplierInfo":{"rating":4.2},"specifications":{"Capacity":"350ml"},"reviewsCount":67,"rating":4.2,"shippingInfo":{},"inventoryLevel":"In Stock"},{"sourceProductId":"SAMPLE007","sourceSite":"sample","title":"🎒 Travel Backpack","description":"Waterproof travel backpack with laptop compartment","sourcePrice":49.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400"],"category":"Travel","availability":true,"supplierInfo":{"rating":4.5},"specifications":{"Capacity":"30L"},"reviewsCount":98,"rating":4.5,"shippingInfo":{},"inventoryLevel":"In Stock"},{"sourceProductId":"SAMPLE008","sourceSite":"sample","title":"🌱 Plant Pot","description":"Ceramic plant pot with drainage","sourcePrice":12.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400"],"category":"Home & Garden","availability":true,"supplierInfo":{"rating":4.1},"specifications":{"Material":"Ceramic"},"reviewsCount":45,"rating":4.1,"shippingInfo":{},"inventoryLevel":"In Stock"},{"sourceProductId":"SAMPLE009","sourceSite":"sample","title":"🏋️ Resistance Bands","description":"Set of 5 resistance bands for fitness","sourcePrice":22.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400"],"category":"Fitness","availability":true,"supplierInfo":{"rating":4.3},"specifications":{"Resistance":"Light to Heavy"},"reviewsCount":112,"rating":4.3,"shippingInfo":{},"inventoryLevel":"In Stock"},{"sourceProductId":"SAMPLE010","sourceSite":"sample","title":"📚 Notebook Set","description":"Set of 3 lined notebooks","sourcePrice":18.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1481178733974-87d62cd0cf34?w=400"],"category":"Office","availability":true,"supplierInfo":{"rating":4.0},"specifications":{"Pages":"200 each"},"reviewsCount":78,"rating":4.0,"shippingInfo":{},"inventoryLevel":"In Stock"},{"sourceProductId":"SAMPLE011","sourceSite":"sample","title":"🎨 Art Supplies Kit","description":"Complete art supplies kit for beginners","sourcePrice":39.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400"],"category":"Arts & Crafts","availability":true,"supplierInfo":{"rating":4.4},"specifications":{"Items":"25 pieces"},"reviewsCount":87,"rating":4.4,"shippingInfo":{},"inventoryLevel":"In Stock"},{"sourceProductId":"SAMPLE012","sourceSite":"sample","title":"🧸 Plush Toy Bear","description":"Soft plush teddy bear for kids","sourcePrice":26.99,"currency":"CAD","images":["https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400"],"category":"Toys","availability":true,"supplierInfo":{"rating":4.8},"specifications":{"Size":"30cm"},"reviewsCount":156,"rating":4.8,"shippingInfo":{},"inventoryLevel":"In Stock"}]' \
		>/dev/null 2>&1 && echo "✅ Sample products imported successfully" || echo "❌ Failed to import sample products"

down: ## Stop all services
	@echo "⏹️  Stopping all services..."
	@docker-compose down

logs: ## View logs from all services
	@docker-compose logs -f

logs-api: ## View Express.js API logs
	@docker-compose logs -f express-api

logs-frontend: ## View Next.js frontend logs
	@docker-compose logs -f nextjs-frontend

logs-agent: ## View Python agent logs
	@docker-compose logs -f python-agent

logs-db: ## View PostgreSQL logs
	@docker-compose logs -f postgres

status: ## Show status of all services
	@echo "📊 Service Status:"
	@docker-compose ps

clean: ## Remove all containers, images, and volumes
	@echo "🧹 Cleaning up Docker resources..."
	@docker-compose down -v --rmi all --remove-orphans
	@docker system prune -f
	@echo "✅ Cleanup completed"

build: ## Build all services
	@echo "🔨 Building all services..."
	@docker-compose build

restart: ## Restart all services
	@echo "🔄 Restarting all services..."
	@docker-compose restart
	@echo "✅ All services restarted!"

backup: ## Backup PostgreSQL database
	@echo "💾 Creating PostgreSQL backup..."
	@mkdir -p backups
	@docker exec ecommerce-postgres pg_dump -U postgres -d EcommerceAI > backups/ecommerce_backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "✅ Database backup created in backups/ directory"

restore: ## Restore PostgreSQL database (use BACKUP_FILE=filename)
	@echo "🔄 Restoring PostgreSQL database..."
	@if [ -z "$(BACKUP_FILE)" ]; then echo "❌ Please specify BACKUP_FILE=filename"; exit 1; fi
	@docker exec -i ecommerce-postgres psql -U postgres -d EcommerceAI < backups/$(BACKUP_FILE)
	@echo "✅ Database restored from $(BACKUP_FILE)"

test: ## Run tests
	@echo "🧪 Running tests..."
	@cd express-api && npm test
	@cd nextjs-frontend && npm run test
	@echo "✅ Tests completed"

shell-api: ## Open shell in Express.js API container
	@docker exec -it ecommerce-express-api /bin/sh

shell-frontend: ## Open shell in Next.js frontend container
	@docker exec -it ecommerce-nextjs-frontend /bin/sh

shell-agent: ## Open shell in Python agent container
	@docker exec -it ecommerce-python-agent /bin/bash

shell-db: ## Open PostgreSQL shell
	@docker exec -it ecommerce-postgres psql -U postgres -d EcommerceAI

update: ## Update all Docker images
	@echo "📦 Updating Docker images..."
	@docker-compose pull
	@docker-compose build --no-cache
	@echo "✅ All images updated!"

install-deps: ## Install dependencies in all projects
	@echo "📦 Installing Node.js dependencies..."
	@cd express-api && npm install
	@cd nextjs-frontend && npm install
	@cd python-agent && pip install -r requirements.txt
	@echo "✅ All dependencies installed"

# End of Makefile
EOF

print_status "Updated Makefile for Node.js stack created"

print_section "Creating monitoring configuration..."

# Create monitoring configuration
mkdir -p monitoring/prometheus
cat > monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'express-api'
    static_configs:
      - targets: ['express-api:3001']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'nextjs-frontend'
    static_configs:
      - targets: ['nextjs-frontend:3000']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
EOF

print_status "Monitoring configuration created"

print_section "Creating database initialization scripts..."

# Create database initialization script
mkdir -p sql-scripts/init
cat > sql-scripts/init/01-init-database.sql << 'EOF'
-- Initialize EcommerceAI PostgreSQL Database (Node.js + Prisma)
-- This script runs automatically when PostgreSQL container starts

-- Create database extensions if they don't exist
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Log initialization
SELECT 'PostgreSQL database initialization completed successfully for Node.js platform' as message;
EOF

print_status "Database initialization scripts created"

print_section "Creating additional configuration files..."

# Create .dockerignore files
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
Dockerfile
.dockerignore
.env
logs
*.log
coverage
.nyc_output
EOF

# Create .dockerignore for each service
cp .dockerignore express-api/.dockerignore
cp .dockerignore nextjs-frontend/.dockerignore

cat > python-agent/.dockerignore << 'EOF'
__pycache__
*.pyc
*.pyo
*.pyd
.Python
.git
.gitignore
README.md
Dockerfile
.dockerignore
.env
logs
*.log
.pytest_cache
.coverage
EOF

print_status "Docker ignore files created"

print_section "Creating development scripts..."

# Create development helper script
cat > scripts/dev-setup.sh << 'EOF'
#!/bin/bash
# Development setup script for AI E-commerce Platform

echo "🚀 Setting up development environment..."

# Install Node.js dependencies
echo "📦 Installing Express.js API dependencies..."
cd express-api && npm install && cd ..

echo "📦 Installing Next.js frontend dependencies..."
cd nextjs-frontend && npm install && cd ..

# Install Python dependencies
echo "🐍 Installing Python agent dependencies..."
cd python-agent && pip install -r requirements.txt && cd ..

echo "✅ Development environment setup completed!"
echo "Run 'make dev' to start all services"
EOF

chmod +x scripts/dev-setup.sh

# Create production deployment script
cat > scripts/deploy-prod.sh << 'EOF'
#!/bin/bash
# Production deployment script

echo "🚀 Deploying to production..."

# Build production images
docker-compose -f docker-compose.yml -f docker-compose.prod.yml build

# Start production services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo "✅ Production deployment completed!"
EOF

chmod +x scripts/deploy-prod.sh

print_status "Development scripts created"

print_section "Creating health check script..."

cat > scripts/health-check.sh << 'EOF'
#!/bin/bash
# Health check script for all services

echo "🏥 Performing comprehensive health checks..."

# Check API health
echo -n "Express.js API: "
if curl -f http://localhost:3001/health > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

# Check Frontend health
echo -n "Next.js Frontend: "
if curl -f http://localhost:3000/ > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

# Check Database health
echo -n "PostgreSQL Database: "
if docker exec ecommerce-postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

# Check Redis health
echo -n "Redis Cache: "
if docker exec ecommerce-redis redis-cli -a RedisPass123! ping > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

# Check Python Agent health
echo -n "Python AI Agent: "
if docker logs ecommerce-python-agent 2>&1 | grep -q "Starting Node.js AI Agent System"; then
    echo "✅ Running"
else
    echo "❌ Not running"
fi

echo ""
echo "📊 Service Status:"
docker-compose ps
EOF

chmod +x scripts/health-check.sh

print_status "Health check script created"

print_section "Creating backup and restore scripts..."

cat > scripts/backup-db.sh << 'EOF'
#!/bin/bash
# Database backup script

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="ecommerce_backup_${TIMESTAMP}.sql"

mkdir -p $BACKUP_DIR

echo "💾 Creating PostgreSQL backup..."
docker exec ecommerce-postgres pg_dump -U postgres -d EcommerceAI > $BACKUP_DIR/$BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "✅ Backup created: $BACKUP_DIR/$BACKUP_FILE"
    
    # Compress backup
    gzip $BACKUP_DIR/$BACKUP_FILE
    echo "✅ Backup compressed: $BACKUP_DIR/$BACKUP_FILE.gz"
    
    # Keep only last 10 backups
    cd $BACKUP_DIR
    ls -t *.gz | tail -n +11 | xargs -r rm
    echo "📁 Cleaned up old backups (keeping 10 most recent)"
else
    echo "❌ Backup failed!"
    exit 1
fi
EOF

chmod +x scripts/backup-db.sh

cat > scripts/restore-db.sh << 'EOF'
#!/bin/bash
# Database restore script

if [ -z "$1" ]; then
    echo "❌ Usage: $0 <backup_file>"
    echo "Available backups:"
    ls -la backups/*.sql.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "⚠️  WARNING: This will replace ALL current database data!"
read -p "Continue? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled"
    exit 0
fi

echo "🔄 Restoring database from $BACKUP_FILE..."

# Decompress if needed
if [[ $BACKUP_FILE == *.gz ]]; then
    gunzip -c "$BACKUP_FILE" | docker exec -i ecommerce-postgres psql -U postgres -d EcommerceAI
else
    docker exec -i ecommerce-postgres psql -U postgres -d EcommerceAI < "$BACKUP_FILE"
fi

if [ $? -eq 0 ]; then
    echo "✅ Database restored successfully!"
else
    echo "❌ Restore failed!"
    exit 1
fi
EOF

chmod +x scripts/restore-db.sh

print_status "Backup and restore scripts created"

print_section "Creating environment templates..."

# Create environment template
cat > .env.example << 'EOF'
# AI-Powered E-commerce Platform Environment Configuration
# Copy this file to .env and update the values

# Database Configuration
DATABASE_URL="postgresql://postgres:YourStrong@Passw0rd123!@postgres:5432/EcommerceAI?schema=public"
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=EcommerceAI
POSTGRES_USER=postgres
POSTGRES_PASSWORD=YourStrong@Passw0rd123!

# Redis Configuration  
REDIS_URL=redis://redis:6379
REDIS_PASSWORD=RedisPass123!

# Security (CHANGE THESE IN PRODUCTION!)
JWT_SECRET=nodejs-super-secret-jwt-key-that-is-exactly-256-bits-long-for-security-2024
SESSION_SECRET=session-secret-key-for-express-sessions
BCRYPT_ROUNDS=12

# API Configuration
API_PORT=3001
FRONTEND_PORT=3000
API_URL=http://express-api:3001
FRONTEND_URL=http://nextjs-frontend:3000

# Stripe Configuration (Update with your keys)
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Environment Settings
NODE_ENV=development
LOG_LEVEL=info
PYTHON_ENV=development
PYTHON_LOG_LEVEL=INFO

# Monitoring
GRAFANA_ADMIN_PASSWORD=admin123
PROMETHEUS_RETENTION_TIME=15d

# Feature flags
ENABLE_REAL_SCRAPING=true
ENABLE_MARKET_RESEARCH=true
EOF

print_status "Environment template created"

print_section "Creating production Docker Compose override..."

cat > docker-compose.prod.yml << 'EOF'
# Production overrides for AI E-commerce Platform
version: '3.8'

services:
  express-api:
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=warn
    restart: always
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M

  nextjs-frontend:
    environment:
      - NODE_ENV=production
      - NEXT_TELEMETRY_DISABLED=1
    restart: always
    command: ["npm", "run", "build && npm", "start"]
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M

  python-agent:
    environment:
      - PYTHON_ENV=production
      - LOG_LEVEL=WARN
    restart: always
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  postgres:
    environment:
      - POSTGRES_MAX_CONNECTIONS=200
    restart: always
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G

  redis:
    restart: always
    deploy:
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl-certs:/etc/nginx/ssl:ro
    depends_on:
      - nextjs-frontend
      - express-api
    restart: always
EOF

print_status "Production Docker Compose override created"

print_section "Setting proper file permissions..."

# Set executable permissions on scripts
chmod +x scripts/*.sh

# Set proper permissions on configuration files
chmod 644 .env .env.example
chmod 644 docker-compose.yml docker-compose.prod.yml
chmod 644 Makefile

# Set permissions on Docker files
find . -name "Dockerfile" -exec chmod 644 {} \;
find . -name ".dockerignore" -exec chmod 644 {} \;

print_status "File permissions set correctly"

print_section "Creating quick-start guide..."

cat > QUICK-START.md << 'EOF'
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
EOF

print_status "Quick-start guide created"

print_section "Creating comprehensive README..."

# Create comprehensive README for Node.js version
cat > README.md << 'EOF'
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
EOF

print_status "README.md documentation created"

print_section "Final setup and validation..."

# Create a simple validation script
cat > validate-setup.sh << 'EOF'
#!/bin/bash
# Validation script to check if all files are created correctly

echo "🔍 Validating AI E-commerce Platform setup..."

REQUIRED_FILES=(
    "docker-compose.yml"
    "Makefile"
    ".env"
    "README.md"
    "QUICK-START.md"
    "express-api/package.json"
    "express-api/Dockerfile"
    "express-api/prisma/schema.prisma"
    "nextjs-frontend/package.json"
    "nextjs-frontend/Dockerfile"
    "nextjs-frontend/next.config.js"
    "python-agent/main.py"
    "python-agent/Dockerfile"
    "python-agent/requirements.txt"
    "monitoring/prometheus/prometheus.yml"
    "scripts/health-check.sh"
)

MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -eq 0 ]; then
    echo "✅ All required files are present!"
    echo "✅ Setup validation passed!"
    return 0
else
    echo "❌ Missing files:"
    for file in "${MISSING_FILES[@]}"; do
        echo "   - $file"
    done
    return 1
fi
EOF

chmod +x validate-setup.sh

# Run validation
if ./validate-setup.sh; then
    print_status "Setup validation passed"
else
    print_warning "Some files may be missing - check validation output"
fi

print_section "Creating final documentation..."

cat > PROJECT-STATUS.md << 'EOF'
# 📊 Project Status - AI E-commerce Platform (Node.js)

## ✅ Completed Components

### Backend (Express.js + TypeScript)
- ✅ Express.js API server with TypeScript
- ✅ Prisma ORM with PostgreSQL
- ✅ JWT authentication system
- ✅ Product management endpoints
- ✅ User registration and login
- ✅ Order processing foundation
- ✅ Redis caching integration
- ✅ Input validation with Zod
- ✅ Security middleware (Helmet, CORS, Rate limiting)

### Frontend (Next.js + React SSR)
- ✅ Next.js 14 with App Router
- ✅ Server-Side Rendering (SSR)
- ✅ TypeScript throughout
- ✅ Tailwind CSS styling
- ✅ Responsive design
- ✅ Product grid with real-time data
- ✅ Loading states and error handling
- ✅ Modern React components with hooks

### AI Agent (Python)
- ✅ Asynchronous product scraping
- ✅ Intelligent pricing algorithms
- ✅ Market research capabilities
- ✅ PostgreSQL integration via API
- ✅ Automated import scheduling
- ✅ Comprehensive logging

### DevOps & Infrastructure
- ✅ Docker Compose with ARM64/M4 Mac support
- ✅ PostgreSQL with performance optimizations
- ✅ Redis for caching and sessions
- ✅ Prometheus monitoring
- ✅ Grafana dashboards
- ✅ Health checks for all services
- ✅ Backup and restore scripts
- ✅ Development and production configurations

### Documentation
- ✅ Comprehensive README
- ✅ Quick-start guide
- ✅ API documentation
- ✅ Troubleshooting guides
- ✅ Management commands (Makefile)

## 🚀 Ready Features

1. **Complete E-commerce Store**: Fully functional with product browsing
2. **AI-Powered Product Import**: Automated product sourcing and pricing
3. **User Authentication**: Registration, login, JWT tokens
4. **Database Management**: PostgreSQL with Prisma ORM
5. **Modern Frontend**: Next.js with React SSR and Tailwind CSS
6. **Monitoring**: Real-time metrics and dashboards
7. **Development Tools**: Hot reloading, logging, debugging
8. **Production Ready**: Optimized Docker setup with security

## 🎯 Immediate Next Steps

1. **Start Development**: `make quick-start`
2. **Add Sample Data**: `make populate-products`
3. **Monitor Services**: `make health-check`
4. **View Logs**: `make logs`

## 💡 Customization Opportunities

- **Payment Integration**: Update Stripe keys for live payments
- **Product Sources**: Customize AI agent scraping targets
- **UI/UX**: Modify Next.js components and Tailwind styles  
- **Business Logic**: Extend Express.js API endpoints
- **Monitoring**: Add custom Grafana dashboards

## 🏆 Technical Achievements

- **Type Safety**: TypeScript throughout the stack
- **Performance**: Optimized for M4 Mac with ARM64 images
- **Scalability**: Microservices architecture with Docker
- **Security**: JWT auth, password hashing, input validation
- **Monitoring**: Comprehensive observability stack
- **Developer Experience**: Hot reloading, detailed logging

---

**Status**: ✅ Production Ready
**Last Updated**: $(date)
**Platform**: Node.js + Next.js + Express.js + PostgreSQL
EOF

print_status "Project status documentation created"

print_section "Generating project summary..."

# Create a final summary and next steps
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    🎉 SETUP COMPLETED! 🎉                       ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}📁 Project Location:${NC} $(pwd)"
echo -e "${CYAN}🗂️  Project Name:${NC} $PROJECT_NAME"
echo -e "${CYAN}📦 Version:${NC} $PROJECT_VERSION"
echo -e "${CYAN}🏗️  Architecture:${NC} Node.js + Next.js + Express.js + PostgreSQL"
echo ""

echo -e "${YELLOW}🚀 QUICK START COMMANDS:${NC}"
echo -e "${GREEN}   make quick-start${NC}     # Start everything (M4 Mac optimized)"
echo -e "${GREEN}   make logs${NC}           # Watch real-time logs"
echo -e "${GREEN}   make health-check${NC}   # Verify all services"
echo -e "${GREEN}   make populate-products${NC} # Add sample products"
echo ""

echo -e "${YELLOW}📱 YOUR NEW E-COMMERCE PLATFORM:${NC}"
echo -e "${BLUE}   🛍️  Store:       http://localhost:3000${NC}  (Next.js with React SSR)"
echo -e "${BLUE}   🔧 API:         http://localhost:3001${NC}  (Express.js + TypeScript)"
echo -e "${BLUE}   📊 Monitoring:  http://localhost:3002${NC}  (Grafana: admin/admin123)"
echo -e "${BLUE}   🐘 Database:    localhost:5432${NC}        (PostgreSQL)"
echo ""

echo -e "${YELLOW}🤖 AI FEATURES READY:${NC}"
echo -e "${GREEN}   ✅ Automated product scraping every 15 minutes${NC}"
echo -e "${GREEN}   ✅ Intelligent pricing with 20% markup${NC}"
echo -e "${GREEN}   ✅ Canadian market optimization${NC}"
echo -e "${GREEN}   ✅ Real-time inventory management${NC}"
echo ""

echo -e "${YELLOW}💳 PAYMENT INTEGRATION:${NC}"
echo -e "${GREEN}   ✅ Stripe integration ready${NC}"
echo -e "${GREEN}   ✅ Update .env with your Stripe keys to go live${NC}"
echo ""

echo -e "${YELLOW}🔧 DEVELOPMENT TOOLS:${NC}"
echo -e "${GREEN}   ✅ TypeScript throughout the stack${NC}"
echo -e "${GREEN}   ✅ Hot reloading for rapid development${NC}"
echo -e "${GREEN}   ✅ Comprehensive logging and monitoring${NC}"
echo -e "${GREEN}   ✅ M4 Mac ARM64 optimized containers${NC}"
echo ""

echo -e "${YELLOW}📚 DOCUMENTATION:${NC}"
echo -e "${GREEN}   📖 README.md         - Complete documentation${NC}"
echo -e "${GREEN}   🚀 QUICK-START.md    - 30-second setup guide${NC}"
echo -e "${GREEN}   📊 PROJECT-STATUS.md - Current status${NC}"
echo ""

echo -e "${PURPLE}🎯 NEXT STEPS:${NC}"
echo "1. ${CYAN}cd $PROJECT_NAME${NC}"
echo "2. ${CYAN}make quick-start${NC}"
echo "3. ${CYAN}Open http://localhost:3000${NC}"
echo "4. ${CYAN}Watch your AI-powered store come to life!${NC}"
echo ""

echo -e "${RED}⚠️  IMPORTANT NOTES:${NC}"
echo -e "${YELLOW}   • First startup may take 3-5 minutes (especially on M4 Mac)${NC}"
echo -e "${YELLOW}   • AI agent imports products every 15 minutes${NC}"
echo -e "${YELLOW}   • Update .env with real Stripe keys for live payments${NC}"
echo -e "${YELLOW}   • Run 'make health-check' to verify everything works${NC}"
echo ""

echo -e "${GREEN}🏆 You now have a complete AI-powered e-commerce platform!${NC}"
echo -e "${GREEN}   Ready for Canadian entrepreneurs with modern Node.js stack.${NC}"
echo ""

print_status "Complete AI-Powered E-commerce Platform (Node.js) setup finished!"

# Set final permissions and ownership
chmod -R 755 scripts/
chmod 644 *.md *.yml .env*

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🎉 Success! Your AI E-commerce Platform is ready to launch! 🎉${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""