# Multi-stage Dockerfile for Helios Marketing Site
# Stage 1: Build stage (for future asset compilation/optimization)
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Add build metadata labels (best practice for container management)
LABEL maintainer="devops@helios-observability.com" \
      version="1.0.0" \
      description="Helios Observability Marketing Website" \
      build-date="${BUILD_DATE}" \
      vcs-ref="${VCS_REF}"

# Install build dependencies (if needed for future asset processing)
# This stage is prepared for future use when we might need to compile assets
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy source files
COPY . .

# Placeholder for future build process (asset compilation, minification, etc.)
# RUN npm run build

# Stage 2: Production stage with Nginx
FROM nginx:1.25-alpine AS production

# Install security updates and essential tools
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        dumb-init \
        curl \
        tzdata && \
    rm -rf /var/cache/apk/*

# Create non-root user for security
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Copy custom Nginx configuration
COPY --from=builder /app/docker/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/docker/default.conf /etc/nginx/conf.d/default.conf

# Copy website files from builder stage
COPY --from=builder --chown=nginx:nginx /app/ /usr/share/nginx/html/

# Remove default Nginx files and set proper permissions
RUN rm -f /usr/share/nginx/html/Dockerfile \
          /usr/share/nginx/html/docker-compose.yml \
          /usr/share/nginx/html/package*.json \
          /usr/share/nginx/html/docker/ \
          /usr/share/nginx/html/.git* \
          /usr/share/nginx/html/README.md && \
    chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx && \
    chmod -R 755 /usr/share/nginx/html

# Create required directories for Nginx
RUN mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp && \
    chown -R nginx:nginx /var/cache/nginx

# Add health check script
COPY docker/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

# Switch to non-root user
USER nginx

# Expose port
EXPOSE 8080

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Use dumb-init to handle signals properly
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start Nginx
CMD ["nginx", "-g", "daemon off;"] 