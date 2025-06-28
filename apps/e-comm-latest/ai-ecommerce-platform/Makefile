# AI-Powered E-commerce Platform - Management Commands

.PHONY: help setup build up down logs clean restart status backup restore test dev prod quick-start

# Default target
help: ## Show this help message
	@echo 'AI-Powered E-commerce Platform - Management Commands'
	@echo
	@echo 'Usage:'
	@echo '  make [command]'
	@echo
	@echo 'Setup Commands:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Initial project setup (copy env file, create directories)
	@echo "🔧 Setting up AI-Powered E-commerce Platform..."
	@if [ ! -f .env ]; then cp .env.example .env; echo "✅ Created .env file - please configure it with your API keys"; fi
	@mkdir -p python-agent/logs python-agent/data
	@mkdir -p dotnet-api/logs
	@mkdir -p blazor-frontend/logs
	@mkdir -p nginx/logs
	@mkdir -p ssl-certs
	@mkdir -p backups
	@echo "✅ Created all necessary directories"
	@echo "📝 Next steps:"
	@echo "   1. Edit .env file with your API keys"
	@echo "   2. Run 'make dev' for development or 'make prod' for production"

dev: ## Start all services in development mode
	@echo "🚀 Starting development environment..."
	@docker-compose up -d --build
	@echo "⏳ Waiting for services to be ready..."
	@sleep 30
	@echo "✅ Development environment started!"
	@echo "📱 Access your applications:"
	@echo "   Frontend:    http://localhost:5000"
	@echo "   API:         http://localhost:7001"
	@echo "   API Docs:    http://localhost:7001/swagger"
	@echo "   Grafana:     http://localhost:3000 (admin/admin123)"

prod: ## Start all services in production mode
	@echo "🚀 Starting production environment..."
	@docker-compose up -d --build
	@echo "⏳ Waiting for services to be ready..."
	@sleep 60
	@$(MAKE) health-check
	@echo "✅ Production environment started!"

health-check: ## Perform health checks on all services
	@echo "🏥 Performing health checks..."
	@if curl -f http://localhost:7001/health > /dev/null 2>&1; then echo "✅ API is healthy"; else echo "❌ API health check failed"; fi
	@if curl -f http://localhost:5000 > /dev/null 2>&1; then echo "✅ Frontend is healthy"; else echo "❌ Frontend health check failed"; fi

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

status: ## Show status of all services
	@echo "📊 Service Status:"
	@docker-compose ps

quick-start: setup dev ## Quick start for new users
	@echo "🎉 Quick start completed!"
	@echo "Your AI-powered e-commerce platform is now running."

clean: ## Remove all containers, images, and volumes
	@echo "🧹 Cleaning up Docker resources..."
	@docker-compose down -v --rmi all --remove-orphans
	@docker system prune -f
	@echo "✅ Cleanup completed"
