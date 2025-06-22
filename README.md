# Helios Observability Marketing Site

A modern, containerized marketing website demonstrating advanced DevOps practices including containerization, monitoring, and automated deployment workflows.

## 🚀 Quick Start

Get the site running locally in under 5 minutes:

```bash
# Clone the repository
git clone https://github.com/helios-observability/marketing-site.git
cd marketing-site

# Start the application with monitoring stack
docker-compose up -d

# Verify the site is running
curl http://localhost:8080/health
```

The site will be available at [http://localhost:8080](http://localhost:8080)

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Docker Commands](#docker-commands)
- [Monitoring & Observability](#monitoring--observability)
- [Testing](#testing)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🏗️ Architecture Overview

This project demonstrates enterprise-grade DevOps practices:

### Technology Stack
- **Frontend**: Static HTML, CSS, JavaScript
- **Web Server**: Nginx (Alpine-based)
- **Containerization**: Docker with multi-stage builds
- **Orchestration**: Docker Compose
- **Monitoring**: Fluentd, Nginx Exporter, Custom health checks
- **Security**: Non-root containers, security headers, vulnerability scanning

### Container Architecture
```
┌─────────────────────────────────────────────────────────┐
│                   Docker Compose Stack                 │
├─────────────────┬─────────────────┬─────────────────────┤
│   Web Service   │   Log Collector │   Metrics Exporter  │
│   (Nginx)       │   (Fluentd)     │   (Nginx Exporter)  │
│   Port: 8080    │   Port: 24224   │   Port: 9113        │
└─────────────────┴─────────────────┴─────────────────────┘
```

## 🔧 Prerequisites

- **Docker**: Version 20.10+ ([Install Docker](https://docs.docker.com/get-docker/))
- **Docker Compose**: Version 2.0+ (included with Docker Desktop)
- **Git**: For version control
- **Node.js**: 18+ (for development tools and scripts)

### Verify Prerequisites
```bash
docker --version
docker-compose --version
node --version
npm --version
```

## 💻 Local Development

### Standard Development Workflow

```bash
# 1. Start the development environment
npm run dev

# 2. View logs in real-time
npm run logs

# 3. Run health checks
npm run health

# 4. Access container shell for debugging
npm run shell
```

### Available NPM Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Start the application stack |
| `npm run dev` | Start with rebuild and live logs |
| `npm stop` | Stop all services |
| `npm run logs` | Follow application logs |
| `npm run health` | Run comprehensive health check |
| `npm test` | Run security and performance tests |
| `npm run clean` | Clean up containers and volumes |

### Development with Live Reload

For active development, mount your local files:

```bash
# Create development override
cat > docker-compose.override.yml << EOF
version: '3.8'
services:
  web:
    volumes:
      - ./index.html:/usr/share/nginx/html/index.html:ro
      - ./assets:/usr/share/nginx/html/assets:ro
EOF

docker-compose up -d
```

## 🐳 Docker Commands

### Building and Running

```bash
# Build the Docker image
docker build -t helios-marketing:latest .

# Run container directly
docker run -d \
  --name helios-web \
  -p 8080:8080 \
  helios-marketing:latest

# Run with custom configuration
docker run -d \
  --name helios-web \
  -p 8080:8080 \
  -v $(pwd)/custom-nginx.conf:/etc/nginx/nginx.conf:ro \
  helios-marketing:latest
```

### Image Optimization

```bash
# View image layers and size
docker history helios-marketing:latest

# Inspect image details
docker inspect helios-marketing:latest

# Security scan with Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image helios-marketing:latest
```

## 📊 Monitoring & Observability

### Health Check Endpoints

| Endpoint | Description | Use Case |
|----------|-------------|----------|
| `/health` | Simple health check | Load balancer health checks |
| `/health/detailed` | Detailed status with metrics | Monitoring systems |
| `/metrics` | Nginx metrics (Prometheus format) | Metrics collection |

### Accessing Monitoring Services

```bash
# Nginx metrics
curl http://localhost:9113/metrics

# Application logs
docker-compose logs -f web

# Health check details
curl http://localhost:8080/health/detailed | jq
```

### Custom Health Checks

The health check script supports multiple modes:

```bash
# Inside container
/usr/local/bin/healthcheck.sh              # Full health check
/usr/local/bin/healthcheck.sh quick        # Quick check
/usr/local/bin/healthcheck.sh verbose      # Verbose output
```

## 🧪 Testing

### Automated Testing

```bash
# Run all tests
npm test

# Security vulnerability scan
npm run test:security

# Performance testing
npm run test:performance

# Code quality checks
npm run lint
npm run validate
```

### Manual Testing

```bash
# Test website responsiveness
curl -w "@curl-format.txt" -o /dev/null http://localhost:8080

# Test security headers
curl -I http://localhost:8080

# Load testing with Apache Bench
ab -n 1000 -c 10 http://localhost:8080/
```

## 🚀 Deployment

### Staging Deployment

```bash
# Deploy to staging environment
npm run deploy:staging

# Verify staging deployment
curl https://staging.helios-observability.com/health
```

### Production Deployment

```bash
# Deploy to production (requires approval)
npm run deploy:production

# Rollback if needed
./scripts/rollback.sh
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BUILD_DATE` | Build timestamp | Current timestamp |
| `VCS_REF` | Git commit hash | Current commit |
| `NGINX_WORKER_PROCESSES` | Number of worker processes | auto |
| `NGINX_WORKER_CONNECTIONS` | Worker connections | 1024 |

## 🔍 Troubleshooting

### Common Issues

**Container won't start:**
```bash
# Check container logs
docker-compose logs web

# Verify health check
docker exec helios-marketing-web /usr/local/bin/healthcheck.sh verbose
```

**Permission denied errors:**
```bash
# Check file permissions
ls -la docker/
chmod +x docker/healthcheck.sh
```

**Port already in use:**
```bash
# Find process using port 8080
lsof -i :8080
# Kill the process or change port in docker-compose.yml
```

### Debug Mode

```bash
# Start in debug mode with additional logging
npm run debug

# Access detailed container information
docker inspect helios-marketing-web
```

### Performance Issues

```bash
# Monitor resource usage
docker stats

# Check Nginx status
curl http://localhost:8080/metrics

# Analyze access logs
docker exec helios-marketing-web tail -f /var/log/nginx/access.log
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test locally: `npm run dev`
4. Run tests: `npm test`
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Code Quality Standards

- All Docker builds must pass security scans
- Health checks must pass consistently
- Performance tests must maintain response times < 200ms
- All changes must include appropriate documentation

## 📚 Additional Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)
- [Container Security](https://kubernetes.io/docs/concepts/security/)
- [Monitoring with Prometheus](https://prometheus.io/docs/guides/nginx/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Version

Current version: **1.0.0**

---

**Built with ❤️ by the Helios DevOps Team**

For support, please contact [devops@helios-observability.com](mailto:devops@helios-observability.com) 