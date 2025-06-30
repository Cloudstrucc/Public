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
