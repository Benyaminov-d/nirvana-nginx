# Nirvana Nginx - Makefile
# Repository: nirvana-nginx (Reverse Proxy & Orchestration)

.PHONY: help setup dev prod start stop clean logs ssl-issue ssl-renew health

# Default target
help:
	@echo "Nirvana Nginx - Orchestration Commands"
	@echo "======================================"
	@echo "Available targets:"
	@echo "  setup       - Setup development environment"
	@echo "  dev         - Start development environment (no SSL)"
	@echo "  prod        - Start production environment (with SSL)"
	@echo "  start       - Start all services"
	@echo "  stop        - Stop all services"
	@echo "  logs        - Show nginx logs"
	@echo "  ssl-issue   - Issue SSL certificates"
	@echo "  ssl-renew   - Renew SSL certificates"
	@echo "  health      - Check all services health"
	@echo "  clean       - Clean containers and volumes"
	@echo ""
	@echo "Prerequisites:"
	@echo "  - Docker and Docker Compose installed"
	@echo "  - .env file configured"
	@echo "  - Domain configured for SSL (production)"

# Setup development environment
setup:
	@echo "=== Setting up Nirvana Nginx ==="
	@echo "Creating shared Docker network..."
	@docker network create nirvana_network || echo "Network already exists"
	@if [ ! -f ".env" ]; then \
		echo "Creating .env from template..."; \
		cp nirvana-nginx.env.template .env; \
		echo "Please edit .env file with your configuration"; \
	fi
	@if [ ! -f ".htpasswd" ]; then \
		echo "Creating .htpasswd file..."; \
		echo "Please create .htpasswd file for basic auth"; \
		echo "Use: htpasswd -c .htpasswd username"; \
	fi
	@echo "Creating certbot directories..."
	@mkdir -p certbot/conf certbot/www
	@echo "Setup complete!"
	@echo ""
	@echo "Network 'nirvana_network' is ready for all services to join."

# Start development environment (no SSL)
dev:
	@echo "=== Starting Development Environment ==="
	@echo "Setting NIRVANA_MODE=development in environment..."
	@export NIRVANA_MODE=development && \
		echo "Starting nginx-local proxy..." && \
		echo "Make sure these services are running in nirvana_network:" && \
		echo "  - nirvana_backend (port 8000)" && \
		echo "  - nirvana_website_dev (port 5173)" && \
		echo "Services will be available at:" && \
		echo "  - Proxy: http://localhost:80 → frontend/backend" && \
		docker compose --profile development up -d

# Start production environment (with SSL)
prod:
	@echo "=== Starting Production Environment ==="
	@echo "Setting NIRVANA_MODE=production in environment..."
	@export NIRVANA_MODE=production && \
		echo "Starting nginx with SSL support..." && \
		echo "Make sure these services are running in nirvana_network:" && \
		echo "  - nirvana_backend (port 8000)" && \
		echo "  - nirvana_website (port 80)" && \
		echo "Services will be available at:" && \
		echo "  - Frontend: https://${DOMAIN}" && \
		echo "  - Backend API: https://${DOMAIN}/api/" && \
		docker compose --profile production up -d

# Start specific nginx service
start-dev:
	@echo "=== Starting Development Nginx ==="
	@docker compose up -d nginx-local

start-prod:
	@echo "=== Starting Production Nginx ==="
	@docker compose up -d nginx cert-init

# Stop all services
stop:
	@echo "=== Stopping All Services ==="
	@docker compose down

# Show nginx logs
logs:
	@docker compose logs -f nginx nginx-local

# Show development logs  
logs-dev:
	@docker compose logs -f nginx-local

# Show production logs
logs-prod:
	@docker compose logs -f nginx certbot

# Issue SSL certificates
ssl-issue:
	@echo "=== Issuing SSL Certificates ==="
	@echo "Domain: ${DOMAIN}"
	@echo "Email: ${CERTBOT_EMAIL}"
	@echo "Make sure nginx is running first!"
	@docker compose --profile production run --rm cert-issue

# Renew SSL certificates
ssl-renew:
	@echo "=== Renewing SSL Certificates ==="
	@docker compose run --rm certbot renew

# Check health of services
health:
	@echo "=== Health Check ==="
	@echo "Checking nginx proxy..."
	@curl -s http://localhost:80 | head -n 5 || echo "Nginx not responding"
	@echo "Checking backend through proxy..."
	@curl -s http://localhost:80/api/health || echo "Backend not reachable through proxy"
	@echo "Checking network connectivity..."
	@docker network ls | grep nirvana_network || echo "nirvana_network not found"
	@echo "Services in network:"
	@docker network inspect nirvana_network --format='{{json .Containers}}' | jq . || echo "Network inspection failed"

# Clean containers and volumes
clean:
	@echo "=== Cleaning Environment ==="
	@docker compose down -v
	@docker system prune -f
	@echo "Cleanup complete"

# Clean network (WARNING: This will disconnect all services)
clean-network:
	@echo "=== Cleaning Network ==="
	@echo "WARNING: This will disconnect all services from nirvana_network"
	@read -p "Continue? (y/N): " confirm && [ "$$confirm" = "y" ] && \
		docker network rm nirvana_network || echo "Network cleanup cancelled"

# Recreate network
recreate-network:
	@echo "=== Recreating Network ==="
	@docker network rm nirvana_network || echo "Network did not exist"
	@docker network create nirvana_network
	@echo "Network recreated. Please restart all services."

# Restart nginx services
restart-nginx-dev:
	@echo "=== Restarting Development Nginx ==="
	@docker compose restart nginx-local

restart-nginx-prod:
	@echo "=== Restarting Production Nginx ==="
	@docker compose restart nginx

# Monitor nginx services
monitor:
	@echo "=== Monitoring Nginx Services ==="
	@watch -n 5 'docker compose ps'

# Production deployment  
deploy:
	@echo "=== Deploying Nginx to Production ==="
	@echo "Prerequisites:"
	@echo "1. Domain configured in .env: ${DOMAIN}"
	@echo "2. Backend running on port 8000" 
	@echo "3. Frontend running on port 3000"
	@echo ""
	@echo "Starting production nginx with SSL..."
	@docker compose --profile production up -d
	@echo "Deployment complete"