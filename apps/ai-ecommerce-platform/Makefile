# AI-Powered E-commerce Platform - Management Commands (FINAL VERSION - ALL FIXES APPLIED)

.PHONY: help setup build up down logs clean restart status backup restore test dev prod quick-start m4-dev m4-logs m4-debug

# Default target
help: ## Show this help message
	@echo 'Complete AI-Powered E-commerce Platform (FINAL - ALL FIXES APPLIED)'
	@echo
	@echo 'Usage:'
	@echo '  make [command]'
	@echo
	@echo 'Setup Commands:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Initial project setup (copy env file, create directories)
	@echo "🔧 Setting up Complete AI-Powered E-commerce Platform (FINAL VERSION)..."
	@mkdir -p python-agent/logs python-agent/data
	@mkdir -p dotnet-api/logs
	@mkdir -p blazor-frontend/logs
	@mkdir -p nginx/logs
	@mkdir -p ssl-certs
	@mkdir -p backups
	@echo "✅ Created all necessary directories"
	@echo "📝 Ready to deploy!"

dev: ## Start all services in development mode
	@echo "🚀 Starting complete development environment (FINAL VERSION - ALL FIXES APPLIED)..."
	@docker-compose up -d --build
	@echo "⏳ Waiting for services to be ready..."
	@sleep 60
	@echo "✅ Development environment started!"
	@echo "📱 Access your applications:"
	@echo "   🛍️  Frontend:    http://localhost:5001 (BEAUTIFUL BOOTSTRAP + ALL FIXES)"
	@echo "   🔧 API:         http://localhost:7001"
	@echo "   📖 API Docs:    http://localhost:7001/swagger"
	@echo "   📊 Grafana:     http://localhost:3001 (admin/admin123)"
	@echo "   🐘 Database:    PostgreSQL on localhost:5432"

m4-dev: ## Start services with M4 Mac optimizations
	@echo "🚀 Starting development environment optimized for M4 Mac (ALL FIXES APPLIED)..."
	@docker-compose up -d --build
	@echo "⏳ Waiting longer for M4 Mac services to be ready..."
	@sleep 120
	@echo "✅ M4 Mac development environment started!"
	@echo "📱 Access your applications:"
	@echo "   🛍️  Frontend:    http://localhost:5001 (BEAUTIFUL BOOTSTRAP + ALL FIXES)"
	@echo "   🔧 API:         http://localhost:7001"
	@echo "   📖 API Docs:    http://localhost:7001/swagger"
	@echo "   📊 Grafana:     http://localhost:3001 (admin/admin123)"

health-check: ## Perform health checks on all services
	@echo "🏥 Performing health checks..."
	@if curl -f http://localhost:7001/health > /dev/null 2>&1; then echo "✅ API is healthy"; else echo "❌ API health check failed"; fi
	@if curl -f http://localhost:5001/health > /dev/null 2>&1; then echo "✅ Frontend is healthy"; else echo "❌ Frontend health check failed"; fi
	@if docker exec ecommerce-postgres pg_isready -U postgres > /dev/null 2>&1; then echo "✅ PostgreSQL is healthy"; else echo "❌ PostgreSQL health check failed"; fi

down: ## Stop all services
	@echo "⏹️  Stopping all services..."
	@docker-compose down

logs: ## View logs from all services
	@docker-compose logs -f

logs-api: ## View API logs
	@docker-compose logs -f dotnet-api

logs-frontend: ## View frontend logs
	@docker-compose logs -f blazor-frontend

logs-agent: ## View Python agent logs
	@docker-compose logs -f python-agent

logs-db: ## View PostgreSQL logs
	@docker-compose logs -f postgres

m4-logs: ## View logs with M4 Mac friendly output
	@echo "📋 M4 Mac Service Logs:"
	@docker-compose logs --tail=50 dotnet-api

status: ## Show status of all services
	@echo "📊 Service Status:"
	@docker-compose ps

quick-start: setup m4-dev ## Quick start for new users (M4 Mac optimized)
	@echo "🎉 Quick start completed!"
	@echo "Your Complete AI-powered e-commerce platform is now running."
	@echo "🎨 Beautiful Bootstrap frontend with ALL FIXES APPLIED at http://localhost:5001"

clean: ## Remove all containers, images, and volumes
	@echo "🧹 Cleaning up Docker resources..."
	@docker-compose down -v --rmi all --remove-orphans
	@docker system prune -f
	@echo "✅ Cleanup completed"

build: ## Build all services
	@echo "🔨 Building all services..."
	@docker-compose build

# @echo "🔄 Restarting all services..."
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
	@cd dotnet-api && dotnet test
	@echo "✅ Tests completed"

prod: ## Start production environment
	@echo "🚀 Starting production environment..."
	@docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
	@echo "✅ Production environment started!"

m4-debug: ## Debug M4 Mac specific issues
	@echo "🔍 M4 Mac Debug Information:"
	@echo "Docker version:"
	@docker --version
	@echo "Docker Compose version:"
	@docker-compose --version
	@echo "Platform architecture:"
	@docker info | grep Architecture || echo "Architecture info not available"
	@echo "Current services:"
	@docker-compose ps

stop-agent: ## Stop just the Python agent
	@docker-compose stop python-agent

start-agent: ## Start just the Python agent
	@docker-compose start python-agent

reset-db: ## Reset PostgreSQL database (WARNING: deletes all data)
	@echo "⚠️  WARNING: This will delete ALL database data!"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ] || exit 1
	@docker-compose down postgres
	@docker volume rm ${PROJECT_NAME}_postgres_data || true
	@docker-compose up -d postgres
	@echo "✅ PostgreSQL database reset completed"

shell-api: ## Open shell in API container
	@docker exec -it ecommerce-dotnet-api /bin/bash

shell-agent: ## Open shell in Python agent container
	@docker exec -it ecommerce-python-agent /bin/bash

shell-db: ## Open PostgreSQL shell
	@docker exec -it ecommerce-postgres psql -U postgres -d EcommerceAI

update: ## Update all Docker images
	@echo "📦 Updating Docker images..."
	@docker-compose pull
	@docker-compose build --no-cache
	@echo "✅ All images updated!"

# End of Makefile
