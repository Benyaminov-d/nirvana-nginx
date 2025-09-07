# Nirvana Nginx

Reverse proxy, SSL termination, and orchestration service for the Nirvana App - a professional fintech application.

## Overview

This repository contains the nginx reverse proxy configuration and Docker Compose orchestration for the complete Nirvana App stack, providing:
- SSL/TLS termination and certificate management
- Load balancing and reverse proxy
- Static file serving
- API routing and CORS handling
- Complete application orchestration

## Architecture

The nginx service acts as the entry point and orchestrates all components:

```
Internet → Nginx (SSL) → Frontend (React SPA)
                    → Backend API (FastAPI)
                    → Database (PostgreSQL)
                    → Cache (Redis)
```

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Domain name configured (for SSL)
- Environment configuration

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/nirvana-nginx.git
   cd nirvana-nginx
   ```

2. **Configure environment:**
   ```bash
   cp nirvana-nginx.env.template .env
   # Edit .env with your domain and configuration
   ```

3. **Create basic auth file:**
   ```bash
   htpasswd -c .htpasswd username
   ```

4. **Start development environment:**
   ```bash
   make setup
   make dev
   ```

### Available Commands

```bash
make help          # Show all available commands
make setup         # Setup development environment
make dev           # Start development environment (no SSL)
make prod          # Start production environment (with SSL)
make start         # Start all services
make stop          # Stop all services
make logs          # Show nginx logs
make ssl-issue     # Issue SSL certificates
make ssl-renew     # Renew SSL certificates
make health        # Check all services health
make clean         # Clean containers and volumes
```

## Configuration

### Environment Variables

Key configuration variables (see `.env.template`):

- `DOMAIN` - Your domain name (e.g., `nirvana.bm`)
- `CERTBOT_EMAIL` - Email for SSL certificate registration
- `POSTGRES_PASSWORD` - Database password
- `BASIC_AUTH_USER/PASS` - Basic authentication credentials
- `NIR_ALLOWED_ORIGINS` - CORS allowed origins

### SSL Configuration

The nginx service handles SSL/TLS termination:
- **Development**: HTTP only (port 80)
- **Production**: HTTPS with Let's Encrypt certificates (ports 80, 443)

### Service Discovery

Services communicate via Docker networking:
- Backend: `nirvana_backend:8000`
- Frontend: `nirvana_frontend:80`
- Database: `db:5432`
- Redis: `redis:6379`

## Services Orchestration

### Complete Stack

The docker-compose.yml orchestrates all services:

1. **Database** (PostgreSQL with pgvector)
2. **Redis** (Caching and sessions)
3. **Backend** (FastAPI application)
4. **Frontend** (React SPA)
5. **Nginx** (Reverse proxy and SSL)

### Service Dependencies

```
nginx → frontend → backend → database
                    ↓
                  redis
```

## Nginx Configuration

### Production (nginx.conf)

- SSL/TLS termination
- HTTP to HTTPS redirect
- API routing (`/api/*` → backend)
- Static file serving
- CORS headers
- Rate limiting
- Security headers

### Development (nginx.local.conf)

- HTTP only (no SSL)
- Direct service routing
- Development-friendly timeouts
- CORS configuration

## SSL Certificate Management

### Automatic Certificate Issuance

```bash
make ssl-issue
```

This will:
1. Start nginx with temporary certificates
2. Issue Let's Encrypt certificates
3. Restart nginx with real certificates

### Certificate Renewal

```bash
make ssl-renew
```

Certificates are automatically renewed via the certbot service.

## Development Workflow

### Local Development

1. **Start development environment:**
   ```bash
   make dev
   ```

2. **Access services:**
   - Frontend: http://localhost:80
   - Backend API: http://localhost:8000
   - Frontend Dev: http://localhost:5173

### Production Deployment

1. **Configure domain and SSL:**
   ```bash
   # Edit .env with your domain
   make ssl-issue
   ```

2. **Deploy:**
   ```bash
   make prod
   ```

## Monitoring and Maintenance

### Health Checks

```bash
make health
```

Checks all services:
- Backend API health endpoint
- Frontend availability
- Nginx response

### Logs

```bash
make logs          # Nginx logs only
make logs-all      # All services logs
```

### Service Management

```bash
make restart-backend    # Restart backend only
make restart-frontend   # Restart frontend only
make restart-nginx      # Restart nginx only
```

## Security Features

### SSL/TLS
- TLS 1.2 and 1.3 support
- Strong cipher suites
- HSTS headers
- Certificate auto-renewal

### Rate Limiting
- Per-IP request limiting
- Burst handling
- API endpoint protection

### Authentication
- Basic Auth for protected routes
- CORS configuration
- Security headers

### Access Control
- Whitelist-based API access
- Static file protection
- Directory traversal prevention

## Performance Optimization

### Caching
- Static file caching
- Gzip compression
- Browser caching headers

### Load Balancing
- Upstream service configuration
- Health checks
- Failover handling

### Resource Management
- Connection pooling
- Timeout configuration
- Memory optimization

## Troubleshooting

### Common Issues

1. **SSL Certificate Issues:**
   ```bash
   make ssl-renew
   ```

2. **Service Not Starting:**
   ```bash
   make logs
   docker compose ps
   ```

3. **Database Connection Issues:**
   ```bash
   make db-shell
   ```

4. **Frontend Not Loading:**
   - Check `VITE_API_BASE` configuration
   - Verify backend is running
   - Check nginx logs

### Debug Commands

```bash
make monitor        # Real-time service monitoring
make db-backup      # Backup database
make clean          # Clean environment
```

## Backup and Recovery

### Database Backup

```bash
make db-backup
```

### Configuration Backup

```bash
# Backup nginx configs
cp nginx.conf nginx.conf.backup
cp nginx.local.conf nginx.local.conf.backup
```

## Scaling

### Horizontal Scaling

To scale backend services:

```yaml
# In docker-compose.yml
backend:
  deploy:
    replicas: 3
```

### Load Balancer Configuration

For production, consider using an external load balancer (AWS ALB, Azure Load Balancer) in front of nginx.

## Contributing

1. Test configuration changes locally
2. Update documentation
3. Follow nginx best practices
4. Ensure SSL security standards

## License

This project is proprietary software. All rights reserved.

## Support

For technical support or questions, contact the development team.